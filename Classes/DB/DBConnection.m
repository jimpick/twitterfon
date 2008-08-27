#import "DBConnection.h"
#import "TimeUtils.h"

static sqlite3*             theDatabase = nil;

@implementation DBConnection

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        Stopwatch *s = [Stopwatch stopwatch];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"db1.1.sql"];
        // Open the database. The database was prepared outside the application.
        [s lap:@"Open DB..."];
        if (sqlite3_open([path UTF8String], &theDatabase) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(theDatabase);
            NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(theDatabase));
            // Additional error handling, as appropriate...
        }
        [s lap:@"Init DB"];
    }
    return theDatabase;
}

#define NUM_QUERIES 4

const char * sqls[NUM_QUERIES] = {
    "DELETE FROM images WHERE updated_at <= (SELECT updated_at FROM images order by updated_at LIMIT 1 OFFSET 1000)",
#if 1   
    "DELETE FROM messages WHERE type = 0 and id <= (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 200)",
    "DELETE FROM messages WHERE type = 1 and id <= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 200)",
    "DELETE FROM messages WHERE type = 2 and id <= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 200)",
#else
    "DELETE FROM messages WHERE type = 0 and id > (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 20)",
    "DELETE FROM messages WHERE type = 1 and id >= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 5)",
    "DELETE FROM messages WHERE type = 2 and id >= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 5)",
#endif
};

+ (void)deleteOldCache
{
    int i;
    int success;
    char *errmsg;
    
    Stopwatch *s = [Stopwatch stopwatch];
    for (i = 0; i < NUM_QUERIES; ++i) {
        success = sqlite3_exec(theDatabase, sqls[i], NULL, NULL, &errmsg);
        if (success != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to cleanup chache (%s)", errmsg);
        }
    }
    [s lap:@"clear cache"];
}

@end
