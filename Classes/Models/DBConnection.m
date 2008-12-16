#import "DBConnection.h"

static sqlite3*             theDatabase = nil;

#define MAIN_DATABASE_NAME @"db1.3.sql"

//#define TEST_DELETE_TWEET

#ifdef TEST_DELETE_TWEET
const char *delete_tweets = 
"BEGIN;"
//"DELETE FROM messages;"
//"DELETE FROM images;"
//"DELETE FROM messages WHERE type = 0 and id > (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 1);"
//"DELETE FROM messages WHERE type = 1 and id > (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 1);"
//"DELETE FROM messages WHERE type = 2 and id > (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 1);"
//"DELETE FROM messages WHERE type = 3 and id > (SELECT id FROM messages WHERE type = 3 ORDER BY id DESC LIMIT 1 OFFSET 1);"
"COMMIT";
#endif

@implementation DBConnection

+ (sqlite3*)openDatabase:(NSString*)dbFilename
{
    sqlite3* instance;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(instance);
        NSLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        theDatabase = [self openDatabase:MAIN_DATABASE_NAME];
        NSAssert1(theDatabase, @"Can't open cache database. Please re-install TwitterFon", nil);
        
#ifdef TEST_DELETE_TWEET
        char *errmsg;
        if (sqlite3_exec(theDatabase, delete_tweets, NULL, NULL, &errmsg) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
        }
#endif
    }
    return theDatabase;
}

//
// delete caches
//
const char *delete_message_cache_sql = 
"BEGIN;"
"DELETE FROM messages;"
"DELETE FROM users;"
"DELETE FROM followees;"
"COMMIT;"
"VACUUM;";

+ (void)deleteMessageCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, delete_message_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

+ (void)deleteImageCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, "DELETE FROM images; VACUUM;", NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

//
// cleanup and optimize
//
const char *cleanup_sql =
"BEGIN;"
"DELETE FROM images WHERE updated_at <= (SELECT updated_at FROM images order by updated_at LIMIT 1 OFFSET 5000);"
"DELETE FROM messages WHERE type = 0 and id <= (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 1000);"
"DELETE FROM messages WHERE type = 1 and id <= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 1000);"
"DELETE FROM messages WHERE type = 2 and id <= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 1000);"
"DELETE FROM messages WHERE type = 3 and id <= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 1000);"
"COMMIT";


const char *optimize_sql = 
"REINDEX messages;"
"REINDEX images;"
"REINDEX users;"
"ANALYZE messages;"
"ANALYZE images;"
"ANALYZE users;"
"VACUUM;";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            // ignore error
            NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
        
      	int launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        NSLog(@"launchCount %d", launchCount);
        if (launchCount-- <= 0) {
            NSLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 50;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

//
// migration
//
const char *update_v12_to_v13 = 
// Create database
"BEGIN;"
"CREATE TABLE messages_new (        \
'id'                     INTEGER,   \
'type'                   INTEGER,   \
'user_id'                INTEGER,   \
'text'                   TEXT,      \
'created_at'             INTEGER,   \
'source'                 TEXT,      \
'favorited'              INTEGER,   \
'cell_height'            INTEGER,   \
'in_reply_to_status_id'  INTEGER,   \
'in_reply_to_user_id'    INTEGER,   \
'truncated'              INTEGER,   \
PRIMARY KEY(type, id)               \
);"
"CREATE TABLE users (   \
'user_id'                INTEGER PRIMARY KEY,    \
'name'                   TEXT,   \
'screen_name'            TEXT,   \
'location'               TEXT,   \
'description'            TEXT,   \
'url'                    TEXT,   \
'followers_count'        INTEGER,\
'profile_image_url'      TEXT,   \
'protected'              INTEGER \
);"
// Drop & Create index
"DROP INDEX users_name;"
"DROP INDEX users_screen_name;"
"CREATE INDEX users_name on users(name);"
"CREATE INDEX users_screen_name on users(screen_name);"
"CREATE INDEX followees_name on followees(name);"
"CREATE INDEX followees_screen_name on followees(screen_name);"
// Copy data from old database
"INSERT INTO users (user_id, name, screen_name, profile_image_url) SELECT * FROM followees;"
"REPLACE INTO users SELECT user_id, name, screen_name, location, descripton, url, followers_count, profile_image_url, protected FROM messages ORDER BY id;"
"INSERT INTO messages_new (id, type, user_id, text, created_at, source, favorited, cell_height) SELECT id, type, user_id, text, created_at, source, favorited, cell_height FROM messages;"
"DROP TABLE messages;"
"ALTER TABLE messages_new RENAME TO messages;"
"COMMIT;"
// Optimize
"REINDEX messages;"
"REINDEX users;"
"REINDEX images;"
"ANALYZE messages;"
"ANALYZE images;"
"ANALYZE users;"
"VACUUM;";

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    
    // Update from version 1.2
    NSString *oldDBPath = [documentsDirectory stringByAppendingPathComponent:@"db1.2.sql"];
    success = [fileManager fileExistsAtPath:oldDBPath];
    if (success) {
        sqlite3 *db12 = [DBConnection openDatabase:@"db1.2.sql"];
        char *errmsg;
        if (sqlite3_exec(db12, update_v12_to_v13, NULL, NULL, &errmsg) == SQLITE_OK) {
            // succeeded to update.
            [fileManager moveItemAtPath:oldDBPath toPath:writableDBPath error:&error];
            NSLog(@"Updated database from version 1.2 to 1.3.");
            return;
        }
        NSLog(@"Failed to update database (Reason: %s). Discard version 1.2 data...", errmsg);
        [fileManager removeItemAtPath:oldDBPath error:&error];
    }
    
    // No exists any database file. Create new one.
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end
