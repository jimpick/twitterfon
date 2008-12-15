#import "Message.h"
#import "Followee.h"
#import "sqlite3.h"
#import "DBConnection.h"
#import "REString.h"
#import "StringUtil.h"

static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* select_statement = nil;
static sqlite3_stmt* message_by_id_statement = nil;

@interface Message (Private)
- (void)insertDB;
- (void)updateAttribute;
@end

@implementation Message

@synthesize messageId;
@synthesize user;
@synthesize text;
@synthesize createdAt;
@synthesize source;
@synthesize favorited;
@synthesize timestamp;

@synthesize unread;
@synthesize type;
@synthesize cellType;
@synthesize hasReply;
@synthesize textBounds;
@synthesize textHeight;
@synthesize cellHeight;
@synthesize inReplyToMessageId;
@synthesize inReplyToUserId;
@synthesize truncated;

@synthesize accessoryType;
@synthesize page;

- (void)dealloc
{
    [text release];
    [user release];
    [source release];
    [timestamp release];
  	[super dealloc];
}

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)aType
{
	self = [super init];
    
    type = aType;
    cellType = MSG_CELL_TYPE_NORMAL;
    
	messageId           = [[dic objectForKey:@"id"] longLongValue];
    stringOfCreatedAt   = [dic objectForKey:@"created_at"];

    favorited = [dic objectForKey:@"favorited"] == [NSNull null] ? 0 : [[dic objectForKey:@"favorited"] boolValue];
    
    NSString *tweet = [dic objectForKey:@"text"];

    if ((id)tweet == [NSNull null]) {
        text = @"";
    }
    else {
        tweet = [[tweet  unescapeHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        text  = [[tweet stringByReplacingOccurrencesOfString:@"\r" withString:@" "] retain];
    }

    // parse source parameter
    NSString *src = [dic objectForKey:@"source"];
    if (src == nil) {
        source = @"";
    }
    else if ((id)src == [NSNull null]) {
        source = @"";
    }
    else {
        NSRange r = [src rangeOfString:@"<a href"];
        if (r.location != NSNotFound) {
            NSRange start = [src rangeOfString:@"\">"];
            NSRange end   = [src rangeOfString:@"</a>"];
            if (start.location != NSNotFound && end.location != NSNotFound) {
                r.location = start.location + start.length;
                r.length = end.location - r.location;
                source = [[src substringWithRange:r] retain];
            }
        }
        else {
            source = [src retain];
        }
    }
    
    inReplyToMessageId = [dic objectForKey:@"in_reply_to_status_id"] == [NSNull null] ? 0 : [[dic objectForKey:@"in_reply_to_status_id"] longLongValue];
    inReplyToUserId    = [dic objectForKey:@"in_reply_to_user_id"]   == [NSNull null] ? 0 : [[dic objectForKey:@"in_reply_to_user_id"] longValue];
    truncated          = [dic objectForKey:@"truncated"] == [NSNull null] ? 0 : [[dic objectForKey:@"truncated"] boolValue];
	
	NSDictionary* userDic = [dic objectForKey:@"user"];
	if (userDic) {
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    else {
        if (type == MSG_TYPE_MESSAGES) {
            userDic = [dic objectForKey:@"sender"];
        }
        else {
            userDic = [dic objectForKey:@"recipient"];
        }
        user = [[User alloc] initWithJsonDictionary:userDic];
    }

    [self updateAttribute];
    unread = true;

	return self;
}

- (Message*)initWithSearchResult:(NSDictionary*)dic
{
	self = [super init];
    
    type = MSG_TYPE_SEARCH_RESULT;
    cellType = MSG_CELL_TYPE_NORMAL;
    
	messageId           = [[dic objectForKey:@"id"] longLongValue];
    stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    
    NSString *tweet = [dic objectForKey:@"text"];
    
    if ((id)tweet == [NSNull null]) {
        text = @"";
    }
    else {
        tweet = [[tweet  unescapeHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        text  = [[tweet stringByReplacingOccurrencesOfString:@"\r" withString:@" "] retain];
    }
    
    // parse source parameter
    source = @"";
    
    user = [[User alloc] initWithSearchResult:dic];
    
    [self updateAttribute];
    
	return self;
}


+ (Message*)messageWithLoadMessage:(MessageType)aType page:(int)page
{
    Message *m = [[[Message alloc] init] autorelease];
    m.type = aType;
    m.cellHeight = 48;
    m.page = page;
    m.textBounds = CGRectMake(0, 0, 320, 48);
    m.accessoryType = UITableViewCellAccessoryNone;
    return m;
}

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type
{
	return [[[Message alloc] initWithJsonDictionary:dic type:type] autorelease];
}

+ (Message*)messageWithSearchResult:(NSDictionary*)dic
{
	return [[[Message alloc] initWithSearchResult:dic] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    Message *dist = [[Message allocWithZone:zone] init];
    
	dist.messageId  = messageId;
	dist.user       = [user copy];
    [dist.user release];
	dist.text       = text;
    dist.createdAt  = createdAt;
    dist.source     = source;
    dist.favorited  = favorited;
    dist.timestamp  = timestamp;

    dist.inReplyToMessageId = inReplyToMessageId;
    dist.inReplyToUserId    = inReplyToUserId;
    dist.truncated          = truncated;
    
    dist.unread     = unread;
    dist.hasReply   = hasReply;
    dist.type       = type;
    dist.cellType   = cellType;
    
    // Do not copy following members because they need re-calculate
    //
    //dist.textBounds = textBounds;
    //dist.cellHeight = cellHeight;
    //dist.textHeight = textHeight;
    
    dist.accessoryType = accessoryType;    
    
    return dist;
}

static NSString *userRegexp = @"@([0-9a-zA-Z_]+)";
static NSString *hashRegexp = @"(#[a-zA-Z0-9\\-_\\.+:=]+)";

int sTextWidth[] = {
    CELL_WIDTH,
    USER_CELL_WIDTH,
    DETAIL_CELL_WIDTH,
};

- (void)updateAttribute
{
    // Check link and @username to set accessoryType and set text width
    //
    int textWidth = sTextWidth[cellType];
    
    NSRange range;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int hasUsername = 0;
    hasReply = false;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *tmp = text;
    
    while ([tmp matches:userRegexp withSubstring:array]) {
        NSString *match = [array objectAtIndex:0]; 
        if ([username caseInsensitiveCompare:match] == NSOrderedSame) {
            hasReply = true;
            if (type != MSG_TYPE_REPLIES) {
                ++hasUsername;
            }
        }
        else {
            ++hasUsername;
        }
        range = [tmp rangeOfString:match];
        tmp = [tmp substringFromIndex:range.location + range.length];
        [array removeAllObjects];
    }
    
    tmp = text;
    if ([tmp matches:hashRegexp withSubstring:array]) {
        hasUsername = true;
    }
    
    [array release];
   
    range = [text rangeOfString:@"http://"];
    if (range.location != NSNotFound || hasUsername) {    
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        textWidth -= DETAIL_BUTTON_WIDTH;
    }
    else {
        if (cellType == MSG_CELL_TYPE_DETAIL) {
            accessoryType = UITableViewCellAccessoryNone;
            textWidth -= H_MARGIN;
        }
        else {
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            textWidth -= INDICATOR_WIDTH;
        }
    }

    // Calculate text bounds and cell height here
    //
    [Message calcTextBounds:self textWidth:textWidth];
    
    // Convert timestamp string to UNIX time
    //
    struct tm created;
    setenv("TZ", "GMT", 1);
    time_t now;
    time(&now);
    
    if (!createdAt) {
        if (stringOfCreatedAt) {
            if (strptime([stringOfCreatedAt UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                strptime([stringOfCreatedAt UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
            }
            createdAt = mktime(&created);
        }
    }
}

- (NSString*)timestamp
{
    // Calculate distance time string
    //
    setenv("TZ", "GMT", 1);
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        self.timestamp = [dateFormatter stringFromDate:date];
    }
    return timestamp;
}

+ (void)calcTextBounds:(Message*)message textWidth:(int)textWidth
{
    static UILabel *sLabel = nil;
    static CGRect bounds, result;

    if (message.cellType == MSG_CELL_TYPE_NORMAL) {
        bounds = CGRectMake(0, TOP, textWidth, 200);
    }
    else {
        bounds = CGRectMake(0, 3, textWidth, 200);
    }
    
    if (message.textHeight) {
        result = CGRectMake(bounds.origin.x, bounds.origin.y, textWidth, message.textHeight);
    }
    else {
        if (sLabel == nil) {
            sLabel = [[UILabel alloc] initWithFrame: CGRectZero];        
            sLabel.font = [UIFont systemFontOfSize:13];
            sLabel.numberOfLines = 10;
        }
        
        sLabel.text = message.text;
        result = [sLabel textRectForBounds:bounds limitedToNumberOfLines:10];
    }

    message.textBounds = CGRectMake(bounds.origin.x, bounds.origin.y, textWidth, result.size.height);
    message.textHeight = result.size.height;
    
    if (message.cellType == MSG_CELL_TYPE_NORMAL) {
        result.size.height += 18 + 15 + 2;
        if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    }
    else {
        result.size.height += 22;
    }
    message.cellHeight = result.size.height;
}

+ (Message*)messageWithId:(sqlite_int64)aMessageId
{
    sqlite3* database = [DBConnection getSharedDatabase];
    if (message_by_id_statement == nil) {
        static char *sql = "SELECT * FROM messages,users WHERE messages.user_id = users.user_id AND id = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &message_by_id_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int64(message_by_id_statement, 1, aMessageId);
    int ret = sqlite3_step(message_by_id_statement);
    if (ret != SQLITE_ROW) {
        sqlite3_reset(message_by_id_statement);
        return nil;
    }
    
    Message *m = [Message initWithDB:message_by_id_statement type:MSG_TYPE_FRIENDS];
    sqlite3_reset(message_by_id_statement);
    return m;
}

+ (Message*)initWithDB:(sqlite3_stmt*)statement type:(MessageType)type
{
    // sqlite3 statement should be:
    //  SELECT * FROM messsages,users
    //
    Message *m              = [[[Message alloc] init] autorelease];
    m.user                  = [[User alloc] init];
    
    m.messageId             = (sqlite_int64)sqlite3_column_int64(statement, 0);
    m.text                  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    m.createdAt             = (time_t)sqlite3_column_int(statement, 4);
    m.source                = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
    m.favorited             = (BOOL)sqlite3_column_int(statement, 6);
    m.textHeight            = (uint32_t)sqlite3_column_int(statement, 7);
    m.inReplyToMessageId    = (sqlite_int64)sqlite3_column_int64(statement, 8);
    m.inReplyToUserId       = (uint32_t)sqlite3_column_int64(statement, 9);
    m.truncated             = (BOOL)sqlite3_column_int64(statement, 10);
    
    
    m.user.userId           = (uint32_t)sqlite3_column_int(statement, 11);
    m.user.name             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 12)];
    m.user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 13)];
    m.user.location         = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 14)];
    m.user.description      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 15)];
    m.user.url              = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 16)];
    m.user.followersCount   = (uint32_t)sqlite3_column_int(statement, 17);
    m.user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 18)];
    m.user.protected        = (uint32_t)sqlite3_column_int(statement, 19) ? true : false;
    m.unread                = false;
    m.type                  = type;

    m.cellType = MSG_CELL_TYPE_NORMAL;
    [m updateAttribute];
    
    return m;
}

+ (BOOL)isExists:(sqlite_int64)aMessageId type:(MessageType)aType
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (select_statement== nil) {
        static char *sql = "SELECT id FROM messages WHERE id=? and type=?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int64(select_statement, 1, aMessageId);
    sqlite3_bind_int(select_statement, 2, aType);
    BOOL result = (sqlite3_step(select_statement) == SQLITE_ROW) ? true : false;
    sqlite3_reset(select_statement);
    return result;
}

- (void)insertDB
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (insert_statement == nil) {
        static char *sql = "INSERT INTO messages VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int64(insert_statement, 1, messageId);
    sqlite3_bind_int(insert_statement,   2, type);
    sqlite3_bind_int(insert_statement,   3, user.userId);
    
    sqlite3_bind_text(insert_statement,  4, [text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   5, createdAt);
    sqlite3_bind_text(insert_statement,  6, [source UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   7, favorited);
    sqlite3_bind_int(insert_statement,   8, (uint32_t)textHeight);
    sqlite3_bind_int64(insert_statement, 9, inReplyToMessageId);
    sqlite3_bind_int(insert_statement,  10, inReplyToUserId);
    sqlite3_bind_int(insert_statement,  11, truncated);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }

    // Update user and followee record
    [user updateDB];
    
    if (type == MSG_TYPE_FRIENDS) {
        [Followee insertDB:user];
    }
}

- (void)deleteFromDB
{
    sqlite3* database = [DBConnection getSharedDatabase];

    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(database, "DELETE FROM messages WHERE id = ?", -1, &stmt, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    sqlite3_bind_int64(stmt, 1, messageId);

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    
    // ignore error
#if 0    
    if (success == SQLITE_ERROR) {
        //NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }    
#endif
}

- (void)updateFavoriteState
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    sqlite3_stmt* stmt;
    if (sqlite3_prepare_v2(database, "UPDATE messages SET favorited = ? WHERE id = ?", -1, &stmt, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    sqlite3_bind_int(stmt, 1, favorited);
    sqlite3_bind_int64(stmt, 2, messageId);
    
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    // ignore error
#if 0
    if (success == SQLITE_ERROR) {
        //NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }    
#endif
}

@end
