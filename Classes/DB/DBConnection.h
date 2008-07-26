#import <sqlite3.h>

@interface DBConnection : NSObject
{
    sqlite3*            database;
}

+ (sqlite3*)getSharedDatabase;
+ (void)deleteOldCache:(sqlite3*)db;

@end
