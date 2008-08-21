#import "Message.h"
#import "sqlite3.h"
#import "DBConnection.h"

static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* select_statement = nil;

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
@synthesize textBounds;
@synthesize cellHeight;
@synthesize accessoryType;

- (void)dealloc
{
    [text release];
    [user release];
    [createdAt release];
    [timestamp release];
  	[super dealloc];
}

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)aType
{
	self = [super init];
    
    type = aType;
    
	messageId = [[dic objectForKey:@"id"] longLongValue];
	text      = [[dic objectForKey:@"text"] copy];
    createdAt = [[dic objectForKey:@"created_at"] copy];
    source    = [[dic objectForKey:@"source"] copy];
    favorited = [[dic objectForKey:@"favorited"] isKindOfClass:[NSNull class]] ? 0 : 1;
	
	NSDictionary* userDic = [dic objectForKey:@"user"];
	if (userDic) {
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    else {
        userDic = [dic objectForKey:@"sender"];
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    
    [self insertDB];
    [self updateAttribute];
    unread = true;
    
	return self;
}

- (void)updateAttribute
{
    // Set accessoryType and bounds width
    //
    NSRange r = [text rangeOfString:@"http://"];
    int textWidth = CELL_WIDTH;
    if (r.location != NSNotFound) {    
        //accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        textWidth -= DETAIL_BUTTON_WIDTH;
    }
    else {
        accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    // Calculate cell height here
    //
    CGRect bounds;
    CGRect result;
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.numberOfLines = 10;
    
    textLabel.text = text;
    bounds = CGRectMake(0, 0, textWidth, 200);
    result = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
    result.size.height += 18 + 16;
    if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    cellHeight = result.size.height;
    [textLabel release];

    textBounds = CGRectMake(LEFT, TOP, textWidth, cellHeight - TOP);
    
    // Calculate distance time and create timestamp
    //
    struct tm created;
    setenv("TZ", "GMT", 1);
    strptime([createdAt UTF8String], "%a %b %d %H:%M:%S %z %Y", &created);
    time_t now;
    time(&now);
    int distance = (int)difftime(now, mktime(&created));
    if (distance < 0) distance = 0;

    if (distance < 60) {
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "sec" : "secs"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "min" : "mins"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour" : "hours"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day" : "days"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week" : "weeks"];
    }
    else {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:mktime(&created)];        
        self.timestamp = [dateFormatter stringFromDate:date];
    }

}

+ (Message*)initWithDB:(sqlite3_stmt*)statement type:(MessageType)type
{
    // sqlite3 statement should be:
    //  SELECT id, type, user_id, screen_name, profile_image_url, text, created_at FROM messsages
    //
    Message *m              = [[[Message alloc] init] autorelease];
    m.user                  = [[User alloc] init];
    
    m.messageId             = (sqlite_int64)sqlite3_column_int64(statement, 0);
    m.text                  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
    m.createdAt             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    m.source                = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
    m.favorited             = (BOOL)sqlite3_column_int(statement, 5);
    
    m.user.userId           = (uint32_t)sqlite3_column_int(statement, 6);
    m.user.name             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)];
    m.user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 8)];
    m.user.location         = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 9)];
    m.user.description      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 10)];
    m.user.url              = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 11)];
    m.user.followersCount   = (uint32_t)sqlite3_column_int(statement, 12);
    m.user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 13)];
    m.unread = false;
    [m updateAttribute];
    
    return m;
}


+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type
{
	return [[[Message alloc] initWithJsonDictionary:dic type:type] autorelease];
}

+ (BOOL)isExist:(sqlite_int64)aMessageId type:(MessageType)aType
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
    if ([Message isExist:messageId type:type]) {
        return;
    }
    
    NSLog(@"Insert %lld:%d:%@:%@", messageId, user.userId, user.screenName, text);
    sqlite3* database = [DBConnection getSharedDatabase];

    if (insert_statement == nil) {
        static char *sql = "INSERT INTO messages VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int64(insert_statement, 1, messageId);
    sqlite3_bind_int(insert_statement,   2, type);

    sqlite3_bind_text(insert_statement,  3, [text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement,  4, [createdAt UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement,  5, [source UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   6, favorited);
    
    sqlite3_bind_int(insert_statement,   7, user.userId);
    sqlite3_bind_text(insert_statement,  8, [user.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement,  9, [user.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 10, [user.location UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 11, [user.description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 12, [user.url UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,  13, user.followersCount);
    sqlite3_bind_text(insert_statement, 14, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }

}

@end
