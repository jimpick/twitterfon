#import "ProfileImage.h"
#import "ImageDownloader.h"
#import "DBConnection.h"

@interface NSObject (ImageStoreDelegate)
- (void)profileImageDidGetNewImage:(UIImage*)image delegate:(id)delegate;
@end

//sqlite3 statements
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *select_statement = nil;

@interface ProfileImage (Private)
- (void)requestImage;
+ (sqlite3*)getSharedDatabase;
@end

@implementation ProfileImage

@synthesize image;

- (ProfileImage*)initWithURL:(NSString*)aUrl appDelegate:(id)anAppDelegate delegate:(id)aDelegate
{
	self = [super init];
    url  = [aUrl copy];
    delegate = aDelegate;
    appDelegate = anAppDelegate;
    database = [DBConnection getSharedDatabase];
	
    if (select_statement == nil) {
        const char *sql = "SELECT image FROM images WHERE url=?";
        int ret;
        if ((ret = sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL)) != SQLITE_OK) {
            NSLog(@"%s", sqlite3_errmsg(database));
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }

    // Note that the parameters are numbered from 1, not from 0.
    sqlite3_bind_text(select_statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);    
    if (sqlite3_step(select_statement) == SQLITE_ROW) {
        // Restore image from Database
        int length = sqlite3_column_bytes(select_statement, 0);
        NSData *data = [NSData dataWithBytes:sqlite3_column_blob(select_statement, 0) length:length];
        image = [[UIImage imageWithData:data] retain];
    } else {
        [self requestImage];
    }
    sqlite3_reset(select_statement);

	return self;
}

- (void)insertImage:(ImageDownloader*)sender
{
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO images VALUES(?, ?, DATETIME('now'))";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insert_statement, 2, sender.buf.bytes, sender.buf.length, SQLITE_TRANSIENT);

    int success = sqlite3_step(insert_statement);
    sqlite3_reset(insert_statement);
    
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void)requestImage
{
    ImageDownloader* dl = [[ImageDownloader alloc] initWithDelegate:self];
    [dl get:url];
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	image = [[UIImage imageWithData:sender.buf] retain];
    if (!image) {
        return;
    }
    [self insertImage:sender];

    [appDelegate profileImageDidGetNewImage:image delegate:delegate];
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
}

- (void)dealloc
{
    [url release];
    [image release];
	[super dealloc];
}
@end
