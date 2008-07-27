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

@synthesize unread;
@synthesize textBounds;
@synthesize cellHeight;
@synthesize accessoryType;

- (void)dealloc
{
    [text release];
    [user release];
    [createdAt release];
  	[super dealloc];
}

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)aType
{
	self = [super init];
    
    type = aType;
    
	messageId = [[dic objectForKey:@"id"] longValue];
	text      = [[dic objectForKey:@"text"] copy];
    createdAt = [[dic objectForKey:@"created_at"] copy];
	
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
    result.size.height += 18;
    if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    cellHeight = result.size.height;
    [textLabel release];

    textBounds = CGRectMake(LEFT, TOP, textWidth, cellHeight - TOP);
}

+ (Message*)initWithDB:(sqlite3_stmt*)statement type:(MessageType)type
{
    // sqlite3 statement should be:
    //  SELECT id, type, user_id, screen_name, profile_image_url, text, created_at FROM messsages
    //
    Message *m              = [[[Message alloc] init] autorelease];
    m.user                  = [[User alloc] init];
    m.messageId             = (sqlite_int64)sqlite3_column_int64(statement, 0);
    m.user.userId           = (uint32_t)sqlite3_column_int(statement, 2);
    m.user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    m.user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
    m.text                  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
    m.createdAt             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 6)];
    m.unread = false;
    [m updateAttribute];
    
    return m;
}


+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type
{
	return [[[Message alloc] initWithJsonDictionary:dic type:type] autorelease];
}

- (void)insertDB
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement== nil) {
        static char *sql = "SELECT id FROM messages WHERE id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int(select_statement, 1, messageId);
    if (sqlite3_step(select_statement) == SQLITE_ROW) {
        sqlite3_reset(select_statement);
        return;
    }
    sqlite3_reset(select_statement);
    
    
    NSLog(@"Insert %d:%@:%@", user.userId, user.screenName, text);
    
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO messages VALUES(?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int64(insert_statement,  1, messageId);
    sqlite3_bind_int(insert_statement,  2, type);
    sqlite3_bind_int(insert_statement,  3, user.userId);
    sqlite3_bind_text(insert_statement, 4, [user.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 5, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 6, [text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 7, [createdAt UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }

}

@end
