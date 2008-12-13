#import <sqlite3.h>

@interface DBConnection : NSObject
{
    sqlite3*            database;
}

+ (void)createEditableCopyOfDatabaseIfNeeded;

+ (sqlite3*)openDatabase:(NSString*)dbFilename;
+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)deleteMessageCache;
+ (void)deleteImageCache;

@end
