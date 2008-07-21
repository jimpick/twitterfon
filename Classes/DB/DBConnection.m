#import "DBConnection.h"

static sqlite3*             theDatabase = nil;

@implementation DBConnection

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imagesdb.sql"];
        // Open the database. The database was prepared outside the application.
        if (sqlite3_open([path UTF8String], &theDatabase) != SQLITE_OK) {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(theDatabase);
            NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(theDatabase));
            // Additional error handling, as appropriate...
        }

//        [DBConnection garbageCollection:theDatabase];
    }
    return theDatabase;
}

+ (void)garbageCollection:(sqlite3*)db
{
    sqlite3_stmt *statement;
    const char *sql = "SELECT count(uid) from images";
    if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    }    
    if (sqlite3_step(statement) == SQLITE_ROW) {
        int count = sqlite3_column_int(statement, 0);
        NSLog(@"Database row count = %d", count);
    }
    sqlite3_finalize(statement);

}

@end
