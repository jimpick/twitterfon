#import "DBConnection.h"

static sqlite3*             theDatabase = nil;

@implementation DBConnection

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"db1.1.sql"];
        // Open the database. The database was prepared outside the application.
        if (sqlite3_open([path UTF8String], &theDatabase) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(theDatabase);
            NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(theDatabase));
            // Additional error handling, as appropriate...
        }

        [DBConnection deleteOldCache:theDatabase];
    }
    return theDatabase;
}

const char * sqls[4] = {
    "DELETE FROM images WHERE updated_at <= (SELECT updated_at FROM images order by updated_at LIMIT 1 OFFSET 1000)",
#if 1
    "DELETE FROM messages WHERE type = 0 and id <= (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 200)",
    "DELETE FROM messages WHERE type = 1 and id <= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 200)",
    "DELETE FROM messages WHERE type = 2 and id <= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 200)"
#else
    "DELETE FROM messages WHERE type = 0 and id > (SELECT id FROM messages WHERE type = 0 ORDER BY id DESC LIMIT 1 OFFSET 23)",
    "DELETE FROM messages WHERE type = 1 and id >= (SELECT id FROM messages WHERE type = 1 ORDER BY id DESC LIMIT 1 OFFSET 5)",
    "DELETE FROM messages WHERE type = 2 and id >= (SELECT id FROM messages WHERE type = 2 ORDER BY id DESC LIMIT 1 OFFSET 5)",
#endif
};

+ (void)deleteOldCache:(sqlite3*)db
{
    sqlite3_stmt* statement;
    int i;
    int success;
    
    for (i = 0; i < 4; ++i) {
        if (sqlite3_prepare_v2(db, sqls[i], -1, &statement, NULL) != SQLITE_OK) {
            NSLog(@"%s", sqlite3_errmsg(db));
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
        }
        success = sqlite3_step(statement);
        sqlite3_finalize(statement);
        if (success != SQLITE_DONE) {
            NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(db));
        }
    }
}

@end
