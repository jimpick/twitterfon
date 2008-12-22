#import <sqlite3.h>
#import "Statement.h"

//
// Interface for Database connector
//
@interface DBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded;
+ (void)deleteMessageCache;
+ (void)deleteImageCache;

+ (sqlite3*)getSharedDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (Statement*)statementWithQuery:(const char*)sql;

+ (void)assert;
+ (void)assertWithMessage:(NSString*)message;
+ (NSString*)errorMessage;

@end