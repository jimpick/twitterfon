#import "Message.h"
#import "sqlite3.h"
#import "DBConnection.h"

static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* select_statement = nil;

@interface Message (Private)
- (void)insertDB:(MessageType)type;
@end

@implementation Message

@synthesize messageId;
@synthesize text;
@synthesize user;
@synthesize unread;

- (void)dealloc
{
    [text release];
    [user release];
  	[super dealloc];
}

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type
{
	self = [super init];
    
	messageId = [[dic objectForKey:@"id"] longValue];
	text      = [[dic objectForKey:@"text"] copy];
	
	NSDictionary* userDic = [dic objectForKey:@"user"];
	if (userDic) {
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    else {
        userDic = [dic objectForKey:@"sender"];
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    
    [self insertDB:type];
    unread = true;
    
	return self;
}


+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type
{
	return [[[Message alloc] initWithJsonDictionary:dic type:type] autorelease];
}

- (void)insertDB:(MessageType)type
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement== nil) {
        static char *sql = "SELECT id FROM timelines WHERE id=?";
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
        static char *sql = "INSERT INTO timelines VALUES(?, ?, ?, ?, ?, ?)";
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
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }

}


@end
