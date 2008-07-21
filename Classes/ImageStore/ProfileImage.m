#import "ProfileImage.h"
#import "ImageDownloader.h"
#import "DBConnection.h"

@interface NSObject (ImageStoreDelegate)
- (void)imageStoreDidGetNewImage:(UIImage*)image;
@end

//sqlite3 statements
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *select_statement = nil;
static sqlite3_stmt *update_statement = nil;

@interface ProfileImage (Private)
- (void)requestImage:(User*)user;
- (void)restoreFromDB;
+ (sqlite3*)getSharedDatabase;
@end

@implementation ProfileImage

@synthesize image;
@synthesize user;

- (ProfileImage*)initWithUser:(User*)aUser delegate:(id)aDelegate
{
	self = [super init];
    user = aUser;
    delegate = aDelegate;
    database = [DBConnection getSharedDatabase];
	
    if (select_statement == nil) {
        const char *sql = "SELECT url, image FROM images WHERE user_id=?";
        int ret;
        if ((ret = sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL)) != SQLITE_OK) {
            NSLog(@"%s", sqlite3_errmsg(database));
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // For this query, we bind the primary key to the first (and only) placeholder in the statement.
    // Note that the parameters are numbered from 1, not from 0.
    sqlite3_bind_int(select_statement, 1, user.userId);
    if (sqlite3_step(select_statement) == SQLITE_ROW) {
        NSString *url = [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_statement, 0)];
        if ([url compare:user.profileImageUrl] == 0) {
            [self restoreFromDB];
        }
        else {
            needUpdate = true;
            [self requestImage:user];
        }
    } else {
        [self requestImage:user];
    }
    // Reset the statement for future reuse.
    sqlite3_reset(select_statement);

	return self;
}

- (void)restoreFromDB
{
    int length = sqlite3_column_bytes(select_statement, 1);
    NSData *data = [NSData dataWithBytes:sqlite3_column_blob(select_statement, 1) length:length];
    image = [[UIImage imageWithData:data] retain];
}

- (void)updateImage:(ImageDownloader*)sender
{
    if (update_statement == nil) {
        const char *sql = "UPDATE images set url = ?, image = ?, updated_at = DATETIME('now') where user_id = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    // For this query, we bind the primary key to the first (and only) placeholder in the statement.
    // Note that the parameters are numbered from 1, not from 0.
    sqlite3_bind_text(update_statement, 1, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(update_statement, 2, sender.buf.bytes, sender.buf.length, SQLITE_TRANSIENT);
    sqlite3_bind_int(update_statement,  3, user.userId);
    
    int success = sqlite3_step(update_statement);
    // Reset the query for the next use.
    sqlite3_reset(update_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
    }    
}

- (void)insertImage:(ImageDownloader*)sender
{
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO images VALUES(?, ?, ?, DATETIME('now'))";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_int(insert_statement,  1, user.userId);
    sqlite3_bind_text(insert_statement, 2, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insert_statement, 3, sender.buf.bytes, sender.buf.length, SQLITE_TRANSIENT);

    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)requestImage:(User*)aUser
{
    [[ImageDownloader alloc] imageDownloaderWithDelegate:self url:user.profileImageUrl];
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	image = [[UIImage imageWithData:sender.buf] retain];
    if (needUpdate) {
        [self updateImage:sender];
    }
    else {
        [self insertImage:sender];
    }

	if (delegate && [delegate respondsToSelector:@selector(imageStoreDidGetNewImage:)]) {
		[delegate imageStoreDidGetNewImage:image];
	}
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
}

- (void)dealloc
{
    [image release];
	[super dealloc];
}
@end
