#import <sqlite3.h>

@interface DBConnection : NSObject
{
    sqlite3*            database;
}

+ (sqlite3*)getSharedDatabase;
+ (void)garbageCollection:(sqlite3*)db;

@end
