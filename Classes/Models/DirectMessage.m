#import "TwitterFonAppDelegate.h"
#import "DirectMessage.h"
#import "DBConnection.h"
#import "Followee.h"
#import "REString.h"
#import "StringUtil.h"
#import "Status.h"

@interface DirectMessage(Private)
- (void)insertDB;
@end

@implementation DirectMessage

@synthesize messageId;
@synthesize sender;
@synthesize recipient;
@synthesize senderId;
@synthesize recipientId;
@synthesize senderScreenName;
@synthesize recipientScreenName;
@synthesize senderProfileImageUrl;

@synthesize textRect;
@synthesize needTimestamp;

- (void)dealloc
{
    [senderScreenName release];
    [recipientScreenName release];
    [senderProfileImageUrl release];
  	[super dealloc];
}

- (DirectMessage*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    
	messageId           = [[dic objectForKey:@"id"] longLongValue];
    stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    if ((id)stringOfCreatedAt == [NSNull null]) {
        stringOfCreatedAt = @"";
    }
    
    NSString *tweet = [dic objectForKey:@"text"];

    if ((id)tweet == [NSNull null]) {
        text = @"";
    }
    else {
        tweet = [[tweet unescapeHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        text  = [[tweet stringByReplacingOccurrencesOfString:@"\r" withString:@" "] retain];
    }

    senderScreenName = [[dic objectForKey:@"sender_screen_name"] retain];
    recipientScreenName = [[dic objectForKey:@"sender_screen_name"] retain];
    if (senderScreenName == nil || (id)senderScreenName == [NSNull null]) {
        senderScreenName = @"";
    }
    if (recipientScreenName == nil || (id)recipientScreenName == [NSNull null]) {
        recipientScreenName = @"";
    }
    
	NSDictionary* senderDic = [dic objectForKey:@"sender"];
	if (senderDic) {
        sender = [User userWithJsonDictionary:senderDic];
    }
    NSDictionary* recipientDic = [dic objectForKey:@"recipient"];
	if (recipientDic) {
        recipient = [User userWithJsonDictionary:recipientDic];
    }
    senderId = sender.userId;
    recipientId = recipient.userId;
    
    self.senderProfileImageUrl = sender.profileImageUrl;

    [self updateAttribute];
    unread = true;

	return self;
}

+ (DirectMessage*)messageWithJsonDictionary:(NSDictionary*)dic
{
	return [[[DirectMessage alloc] initWithJsonDictionary:dic] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    DirectMessage *dist = [super copyWithZone:zone];
    
	dist.messageId  = messageId;
	dist.sender     = sender;
	dist.recipient  = recipient;
    dist.senderScreenName      = senderScreenName;
    dist.recipientScreenName   = recipientScreenName;
    dist.senderProfileImageUrl = senderProfileImageUrl;
    
    return dist;
}

- (void)updateAttribute
{
    [super updateAttribute];
    int textWidth = MAX_TEXT_WIDTH;
    
    // Calculate text bounds and cell height here
    //
    CGRect bounds;
    
    bounds = CGRectMake(0, 0, textWidth, 200);
    
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    
    label.font = [UIFont systemFontOfSize:14];
    label.text = text;
    textRect = [label textRectForBounds:bounds limitedToNumberOfLines:10];
    
    [self calcTextBounds:CELL_WIDTH - INDICATOR_WIDTH];
}

+ (DirectMessage*)initWithStatement:(Statement*)stmt
{
    // sqlite3 statement should be:
    //  SELECT id, text, created_at FROM messsages WHERE sender_id = ?
    //
    DirectMessage *dm       = [[[DirectMessage alloc] init] autorelease];
    dm.sender               = nil;
    dm.recipient            = nil;
    
    dm.messageId            = [stmt getInt64:0];
    dm.senderId             = [stmt getInt32:1];
    dm.recipientId          = [stmt getInt32:2];
    dm.text                 = [stmt getString:3];
    dm.createdAt            = [stmt getInt32:4];
    dm.senderScreenName     = [stmt getString:5];
    dm.recipientScreenName  = [stmt getString:6];
    dm.senderProfileImageUrl= [stmt getString:7];
    [dm updateAttribute];

    return dm;
}

+ (int)restore:(NSMutableArray*)array all:(BOOL)all
{
    const char *sql = "SELECT direct_messages.*, users.profile_image_url FROM direct_messages,users \
                       WHERE direct_messages.sender_id = users.user_id GROUP BY sender_id ORDER by id DESC LIMIT ?";

    Statement *stmt = [DBConnection statementWithQuery:sql];
    [stmt bindInt32:all ? 200 : 20 forIndex:1];
   
    int count = 0;
    
    while ([stmt step] == SQLITE_ROW) {
        DirectMessage *dm = [DirectMessage initWithStatement:stmt];
        if ([TwitterFonAppDelegate isMyScreenName:dm.senderScreenName] == false) {
            [array addObject:dm];
            ++count;
        }
    }

    return count;
}

+ (int)getConversation:(int)senderId messages:(NSMutableArray*)messages
{
    static char *sql = "SELECT direct_messages.*, users.profile_image_url FROM direct_messages,users \
                        WHERE direct_messages.sender_id = users.user_id AND (sender_id = ? OR recipient_id = ?) ORDER BY id DESC LIMIT ? OFFSET ?";
    Statement *stmt = [DBConnection statementWithQuery:sql];
    
    [stmt bindInt32:senderId                forIndex:1];
    [stmt bindInt32:senderId                forIndex:2];
    [stmt bindInt32:NUM_MESSAGE_PER_PAGE    forIndex:3];
    [stmt bindInt32:[messages count]        forIndex:4];
    
    int count = 0;
    DirectMessage *dm;
    while ([stmt step] == SQLITE_ROW) {
        dm = [DirectMessage initWithStatement:stmt];
        [messages insertObject:dm atIndex:0];
        ++count;
    }

    return count;
}

+ (BOOL)isExists:(sqlite_int64)anId
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT id FROM direct_messages WHERE id=?"];
        [stmt retain];
    }

    [stmt bindInt64:anId forIndex:1];
    BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
    [stmt reset];
    return result;
}

- (void)insertDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"INSERT INTO direct_messages VALUES(?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    
    [stmt bindInt64:messageId           forIndex:1];
    [stmt bindInt32:sender.userId       forIndex:2];
    [stmt bindInt32:recipient.userId    forIndex:3];
    
    [stmt bindString:text               forIndex:4];
    [stmt bindInt32:createdAt           forIndex:5];
    [stmt bindString:sender.screenName  forIndex:6];
    [stmt bindString:recipient.screenName forIndex:7];
    
    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection assert];
    }
    [stmt reset];
    
    // Update user and followee record
    [sender updateDB];
    [recipient updateDB];

    // Add user to followee database
    [Followee insertDB:sender];
}

- (void)deleteFromDB
{
    Statement* stmt = [DBConnection statementWithQuery:"DELETE FROM direct_messages WHERE id = ?"];
    [stmt bindInt64:messageId forIndex:1];
    [stmt step];    // ignore error
}

@end
