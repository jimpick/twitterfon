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

@synthesize recipient;
@synthesize senderId;
@synthesize recipientId;
@synthesize senderScreenName;
@synthesize recipientScreenName;

- (void)dealloc
{
    [senderScreenName release];
    [recipientScreenName release];
  	[super dealloc];
}

- (DirectMessage*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    
	tweetId             = [[dic objectForKey:@"id"] longLongValue];
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
        user = [User userWithJsonDictionary:senderDic];
    }
    NSDictionary* recipientDic = [dic objectForKey:@"recipient"];
	if (recipientDic) {
        recipient = [User userWithJsonDictionary:recipientDic];
    }
    senderId = user.userId;
    recipientId = recipient.userId;
    
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
    
	dist.recipient  = recipient;
    dist.senderScreenName      = senderScreenName;
    dist.recipientScreenName   = recipientScreenName;
    
    return dist;
}

- (void)updateAttribute
{
    [super updateAttribute];  
    [self calcTextBounds:CELL_WIDTH - INDICATOR_WIDTH];
}

+ (DirectMessage*)initWithStatement:(Statement*)stmt
{
    // sqlite3 statement should be:
    //  SELECT id, text, created_at FROM messsages WHERE sender_id = ?
    //
    DirectMessage *dm       = [[[DirectMessage alloc] init] autorelease];
   
    dm.messageId            = [stmt getInt64:0];
    dm.senderId             = [stmt getInt32:1];
    dm.recipientId          = [stmt getInt32:2];
    dm.text                 = [stmt getString:3];
    dm.createdAt            = [stmt getInt32:4];
    dm.senderScreenName     = [stmt getString:5];
    dm.recipientScreenName  = [stmt getString:6];
    
    dm.sender    = [User userWithId:dm.senderId];
    dm.recipient = [User userWithId:dm.recipientId];    
    
    [dm updateAttribute];

    return dm;
}

+ (int)restore:(NSMutableArray*)array all:(BOOL)all
{
    const char *sql = "SELECT * FROM direct_messages GROUP BY sender_id ORDER by id DESC LIMIT ?";

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

- (int)getConversation:(NSMutableArray*)messages
{
    static char *sql = "SELECT * FROM direct_messages WHERE sender_id = ? OR recipient_id = ? ORDER BY id DESC LIMIT ? OFFSET ?";
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

+ (int)countMessages:(int)userId
{
    Statement* stmt = [DBConnection statementWithQuery:"SELECT count(*) FROM direct_messages WHERE sender_id = ?"];
    [stmt bindInt32:userId forIndex:1];
    
    int ret = 0;
    
    if ([stmt step] == SQLITE_ROW) {
        ret = [stmt getInt32:0];        
    }
    return ret;
}

+ (sqlite_int64)lastSentMessageId
{
    Statement* stmt = [DBConnection statementWithQuery:"SELECT id FROM direct_messages WHERE sender_screen_name = ? ORDER BY id DESC LIMIT 1"];
    [stmt bindString:[TwitterFonAppDelegate getAppDelegate].screenName forIndex:1];
    
    sqlite_int64 ret = 0;
    if ([stmt step] == SQLITE_ROW) {
        ret = [stmt getInt64:0];
    }
    NSLog(@"%lld", ret);
    return ret;
}

- (void)insertDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"INSERT INTO direct_messages VALUES(?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    
    [stmt bindInt64:tweetId             forIndex:1];
    [stmt bindInt32:user.userId         forIndex:2];
    [stmt bindInt32:recipient.userId    forIndex:3];
    
    [stmt bindString:text               forIndex:4];
    [stmt bindInt32:createdAt           forIndex:5];
    [stmt bindString:user.screenName    forIndex:6];
    [stmt bindString:recipient.screenName forIndex:7];
    
    if ([stmt step] != SQLITE_DONE) {
        [DBConnection alert];
    }
    [stmt reset];
    
    // Update user and followee record
    [user updateDB];
    [recipient updateDB];

    // Add user to followee database
    [Followee insertDB:user];
}

- (void)deleteFromDB
{
    Statement* stmt = [DBConnection statementWithQuery:"DELETE FROM direct_messages WHERE id = ?"];
    [stmt bindInt64:tweetId forIndex:1];
    [stmt step];    // ignore error
}

@end
