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

@interface ProfileImage (ProfileImagePrivate)
- (BOOL)resizeImage;
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
        static const char *sql = "SELECT image FROM images WHERE url=?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
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
        [self resizeImage];
    } else {
        [self requestImage];
    }
    sqlite3_reset(select_statement);

	return self;
}

- (void)insertImage:(NSData*)buf
{
    
    if (insert_statement == nil) {
        static const char *sql = "REPLACE INTO images VALUES(?, ?, DATETIME('now'))";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_blob(insert_statement, 2, buf.bytes, buf.length, SQLITE_TRANSIENT);

    int success = sqlite3_step(insert_statement);
    sqlite3_reset(insert_statement);
    
    if (success != SQLITE_DONE) {
        NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }
}

- (void)requestImage
{
    ImageDownloader* dl = [[ImageDownloader alloc] initWithDelegate:self];
    [dl get:url];
}

- (BOOL)resizeImage
{
    // Resize image if needed.
    float width  = image.size.width;
    float height = image.size.height;
    // fail safe
    if (width == 0 || height == 0) return false;
    
    float scale;
    
    NSRange r = [url rangeOfString:@"_bigger."];
    float numPixels = (r.location != NSNotFound) ? 73.0 : 48.0;
    
    if (width > numPixels || height > numPixels) {
        if (width > height) {
            scale = numPixels / height;
            width *= scale;
            height = numPixels;
        }
        else {
            scale = numPixels / width;
            height *= scale;
            width = numPixels;
        }
        
        NSLog(@"Resize image %.0fx%.0f -> (%.0f,%.0f)x(%.0f,%.0f)", image.size.width, image.size.height, 
              0 - (width - numPixels) / 2, 0 - (height - numPixels) / 2, width, height);
        
        UIGraphicsBeginImageContext(CGSizeMake(numPixels, numPixels));
        [image drawInRect:CGRectMake(0 - (width - numPixels) / 2, 0 - (height - numPixels) / 2, width, height)];
        [image release];
        image = UIGraphicsGetImageFromCurrentImageContext();
        [image retain];
        UIGraphicsEndImageContext();
        NSData *jpeg = UIImageJPEGRepresentation(image, 0.8);
        [self insertImage:jpeg];
        return true;
    }
    return false;
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	image = [[UIImage imageWithData:sender.buf] retain];
    if (!image) {
        return;
    }

    if ([self resizeImage] == false)  {
        // Insert to DB
        [self insertImage:sender.buf];
    }

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
