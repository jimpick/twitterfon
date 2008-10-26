#import "DBConnection.h"

static sqlite3*             theDatabase = nil;


//#define TEST_DELETE_TWEET

#ifdef TEST_DELETE_TWEET
const char *delete_tweets = 
"BEGIN;"
//"DELETE FROM messages;"
//"DELETE FROM messages WHERE type = 0 and id > (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 20);"
//"DELETE FROM messages WHERE type = 1 and id > (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 10);"
//"DELETE FROM messages WHERE type = 2 and id > (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 1);"
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

const char *cleanup_sql =
"BEGIN;"
"DELETE FROM images WHERE updated_at <= (SELECT updated_at FROM images order by updated_at LIMIT 1 OFFSET 1000);"
"DELETE FROM messages WHERE type = 0 and id <= (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 200);"
"DELETE FROM messages WHERE type = 1 and id <= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 200);"
"DELETE FROM messages WHERE type = 2 and id <= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 200);"
"COMMIT";


const char *optimize_sql = 
"REINDEX messages;"
"REINDEX images;"
"ANALYZE messages;"
"ANALYZE images;"
"VACUUM;";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
        }
        
      	int launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        NSLog(@"launchCount %d", launchCount);
        if (launchCount > 50) {
            NSLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 0;
        }
        ++launchCount;
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

@end
