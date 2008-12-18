#import "DirectMessage.h"
#import "DBConnection.h"
#import "Followee.h"
#import "REString.h"
#import "StringUtil.h"
#import "Status.h"

static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* select_statement = nil;
static sqlite3_stmt* restore_statement = nil;
static sqlite3_stmt* conversation_statement = nil;

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
    [sender release];
    [recipient release];
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
        sender = [[User alloc] initWithJsonDictionary:senderDic];
    }
    NSDictionary* recipientDic = [dic objectForKey:@"recipient"];
	if (recipientDic) {
        recipient = [[User alloc] initWithJsonDictionary:recipientDic];
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
    DirectMessage *dist = [[DirectMessage allocWithZone:zone] init];
    
	dist.messageId  = messageId;
	dist.sender     = [sender copy];
	dist.recipient  = [recipient copy];
    [dist.sender release];
    [dist.recipient release];
    dist.senderScreenName      = senderScreenName;
    dist.recipientScreenName   = recipientScreenName;
    dist.senderProfileImageUrl = senderProfileImageUrl;

    [super copyWithZone:dist];
    
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
}

+ (DirectMessage*)initWithDB:(sqlite3_stmt*)statement
{
    // sqlite3 statement should be:
    //  SELECT id, text, created_at FROM messsages WHERE sender_id = ?
    //
    DirectMessage *dm       = [[[DirectMessage alloc] init] autorelease];
    dm.sender               = nil;
    dm.recipient            = nil;
    
    dm.messageId            = (sqlite_int64)sqlite3_column_int64(statement, 0);
    dm.senderId             = (int)sqlite3_column_int(statement, 1);
    dm.recipientId          = (int)sqlite3_column_int(statement, 2);
    dm.text                 = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    dm.createdAt            = (time_t)sqlite3_column_int(statement, 4);
    dm.senderScreenName     = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
    dm.recipientScreenName  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 6)];
    dm.senderProfileImageUrl= [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)];    
    [dm updateAttribute];
    
    return dm;
}

+ (int)restore:(NSMutableArray*)array all:(BOOL)all
{
    if (restore_statement == nil) {
        const char *sql = "SELECT direct_messages.*, users.profile_image_url FROM direct_messages,users \
                           WHERE direct_messages.sender_id = users.user_id GROUP BY sender_id ORDER by id DESC LIMIT ?";
        restore_statement = [DBConnection prepate:sql];
    }
    
    sqlite3_bind_int(restore_statement, 1, all ? 1000 : 20);
   
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    int count = 0;
    while (sqlite3_step(restore_statement) == SQLITE_ROW) {
        DirectMessage *dm = [DirectMessage initWithDB:restore_statement];
        if ([username caseInsensitiveCompare:dm.senderScreenName] != NSOrderedSame) {

            [array addObject:dm];
            ++count;
        }
    }
    sqlite3_reset(restore_statement);

    return count;
}

+ (int)getConversation:(int)senderId messages:(NSMutableArray*)messages all:(BOOL)all
{
    if (conversation_statement == nil) {
        static char *sql = "SELECT direct_messages.*, users.profile_image_url FROM direct_messages,users \
                            WHERE direct_messages.sender_id = users.user_id AND (sender_id = ? OR recipient_id = ?) ORDER BY id LIMIT ? OFFSET ?";
        conversation_statement = [DBConnection prepate:sql];
    }
    
    sqlite3_bind_int(conversation_statement, 1, senderId);
    sqlite3_bind_int(conversation_statement, 2, senderId);
    sqlite3_bind_int(conversation_statement, 3, all ? 10000 : 40);
    sqlite3_bind_int(conversation_statement, 4, [messages count]);

    int count = 0;
    time_t prev = 0;
    while (sqlite3_step(conversation_statement) == SQLITE_ROW) {
        DirectMessage *dm = [DirectMessage initWithDB:conversation_statement];
        dm.cellType = TWEET_CELL_TYPE_NORMAL;
        int diff = dm.createdAt - prev;
        if (diff > TIMESTAMP_DIFF) {
            DirectMessage *tm = [[DirectMessage alloc] init];
            tm.cellType = TWEET_CELL_TYPE_TIMESTAMP;
            tm.createdAt = dm.createdAt;
            [messages addObject:tm];
        }
        [messages addObject:dm];
        prev = dm.createdAt;
        ++count;
    }
    sqlite3_reset(conversation_statement);
    return count;
}

+ (BOOL)isExists:(sqlite_int64)anId
{
    if (select_statement== nil) {
        select_statement = [DBConnection prepate:"SELECT id FROM direct_messages WHERE id=?"];
    }
    
    sqlite3_bind_int64(select_statement, 1, anId);
    BOOL result = (sqlite3_step(select_statement) == SQLITE_ROW) ? true : false;
    sqlite3_reset(select_statement);
    return result;
}

- (void)insertDB
{
    if (insert_statement == nil) {
        insert_statement = [DBConnection prepate:"INSERT INTO direct_messages VALUES(?, ?, ?, ?, ?, ?, ?)"];
    }
    sqlite3_bind_int64(insert_statement, 1, messageId);
    sqlite3_bind_int(insert_statement,   2, sender.userId);
    sqlite3_bind_int(insert_statement,   3, recipient.userId);
    
    sqlite3_bind_text(insert_statement,  4, [text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   5, createdAt);
    sqlite3_bind_text(insert_statement,  6, [sender.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement,  7, [recipient.screenName UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }

    // Update user and followee record
    [sender updateDB];
    [recipient updateDB];

    // Add user to followee database
    [Followee insertDB:sender];
}

- (void)deleteFromDB
{
    sqlite3_stmt* stmt = [DBConnection prepate:"DELETE FROM direct_messages WHERE id = ?"];

    sqlite3_bind_int64(stmt, 1, messageId);

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    
    // ignore error
#if 0    
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }    
#endif
}

@end
