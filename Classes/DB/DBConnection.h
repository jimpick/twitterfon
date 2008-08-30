#import <sqlite3.h>

#define MAIN_DATABASE_NAME @"db1.1.1.sql"

@interface DBConnection : NSObject
{
    sqlite3*            database;
}

+ (sqlite3*)openDatabase:(NSString*)dbFilename;
+ (sqlite3*)getSharedDatabase;
+ (void)deleteOldCache;

@end
