#import <sqlite3.h>

@interface DBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded;

+ (sqlite3*)openDatabase:(NSString*)dbFilename;
+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)deleteMessageCache;
+ (void)deleteImageCache;

+ (sqlite3_stmt*)prepate:(const char*)sql;

+ (void)assert;
+ (void)assertWithMessage:(NSString*)message;
+ (NSString*)errorMessage;

@end
