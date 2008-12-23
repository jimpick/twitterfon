#import "ProfileImage.h"
#import "ImageDownloader.h"
#import "TwitterFonAppDelegate.h"
#import "DBConnection.h"

@interface ProfileImage (Private)
- (BOOL)resizeImage;
- (void)convertImage;
@end

@implementation ProfileImage

@synthesize image;
@synthesize url;
@synthesize downloader;

- (ProfileImage*)initWithURL:(NSString*)aUrl imageStore:(ImageStore*)aStore
{
	self  = [super init];
    url   = [aUrl copy];
    store = aStore;
    image = nil;

    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT image FROM images WHERE url=?"];
        [stmt retain];
    }

    // Note that the parameters are numbered from 1, not from 0.
    [stmt bindString:url forIndex:1];
    if ([stmt step] == SQLITE_ROW) {
        // Restore image from Database
        NSData *data = [stmt getData:0];
        image = [[UIImage imageWithData:data] retain];
        [self resizeImage];
        [self convertImage];
    }
    [stmt reset];

	return self;
}

- (void)requestImage
{
    [self retain];
    downloader = [[ImageDownloader alloc] initWithDelegate:self];
    [downloader get:url];
}

- (void)insertImage:(NSData*)buf
{ 
    static Statement* stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO images VALUES(?, ?, DATETIME('now'))"];
        [stmt retain];
    }
    [stmt bindString:url forIndex:1];
    [stmt bindData:buf forIndex:2];

    if ([stmt step] != SQLITE_DONE) {
        [DBConnection assert];
    }
    [stmt reset];
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

- (void)convertImage
{
    NSRange r = [url rangeOfString:@"_bigger."];
    float numPixels = (r.location != NSNotFound) ? 73.0 : 48.0;
    float radius = (r.location != NSNotFound) ? 8.0 : 4.0;

    UIGraphicsBeginImageContext(CGSizeMake(numPixels, numPixels));
    CGContextRef c = UIGraphicsGetCurrentContext();

    CGContextBeginPath(c);
    CGContextMoveToPoint  (c, numPixels, numPixels/2);
    CGContextAddArcToPoint(c, numPixels, numPixels, numPixels/2, numPixels,   radius);
    CGContextAddArcToPoint(c, 0,         numPixels, 0,           numPixels/2, radius);
    CGContextAddArcToPoint(c, 0,         0,         numPixels/2, 0,           radius);
    CGContextAddArcToPoint(c, numPixels, 0,         numPixels,   numPixels/2, radius);
    CGContextClosePath(c);

    CGContextClip(c);

    [image drawAtPoint:CGPointZero];
    [image release];
    image = UIGraphicsGetImageFromCurrentImageContext();
    [image retain];
    UIGraphicsEndImageContext();
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	image = [[UIImage imageWithData:sender.buf] retain];

    if (image) {
        if ([self resizeImage] == false)  {
            // Insert to DB
            [self insertImage:sender.buf];
        }
        [self convertImage];
    }

    [store getPendingImage:self];
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
    [store getPendingImage:self];
}

- (void)dealloc
{
    [downloader cancel];
    [downloader release];
    [url release];
    [image release];
	[super dealloc];
}

@end
