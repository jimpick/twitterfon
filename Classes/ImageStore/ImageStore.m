#import "ImageStore.h"
#import "DebugUtils.h"
#import "DBConnection.h"
#import "ImageDownloader.h"

#define MAX_CONNECTION 5

static UIImage *sProfileImage = nil;
static UIImage *sProfileImageSmall = nil;

@interface ImageStore(Private)
- (UIImage*)getImageFromDB:(NSString*)url;
- (void)insertImage:(NSData*)buf forURL:(NSString*)url;
- (UIImage*)resizeImage:(UIImage*)image forURL:(NSString*)str;
- (UIImage*)convertImage:(UIImage*)image forURL:(NSString*)str;
+ (UIImage*)defaultProfileImage:(BOOL)bigger;
@end


@implementation ImageStore

- (id)init
{
	self = [super init];
    images    = [[NSMutableDictionary dictionary] retain];
    pending   = [[NSMutableDictionary dictionary] retain];
    delegates = [[NSMutableDictionary dictionary] retain];
    return self;
}

- (void)dealloc
{
    [delegates release];
    [pending release];
    [images release];
	[super dealloc];
}

- (UIImage*)getProfileImage:(NSString*)anURL isLarge:(BOOL)isLarge delegate:(id)delegate
{
    NSString *url;
    if (isLarge) {
        url = [anURL stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
    }
    else {
        url = anURL;    
    }        
    
    UIImage *image = [images objectForKey:url];
    if (image) {
        return image;
    }

    image = [self getImageFromDB:url];
    if (image) {
        [images setObject:image forKey:url];
        return image;
    }
        

    ImageDownloader *dl = [pending objectForKey:url];
    if (dl == nil) {
        dl = [[[ImageDownloader alloc] initWithDelegate:self] autorelease];
        [pending setObject:dl forKey:url];
    }

    NSMutableArray *arr = [delegates objectForKey:url];
    if (arr) {
        [arr addObject:delegate];
    }
    else {
        [delegates setObject:[NSMutableArray arrayWithObject:delegate] forKey:url];
    }
    if ([pending count] <= MAX_CONNECTION && dl.requestURL == nil) {
        [dl get:url];
    }
    
    return [ImageStore defaultProfileImage:isLarge];
}


- (void)getPendingImage:(ImageDownloader*)sender
{
    [pending removeObjectForKey:sender.requestURL];
    
    NSArray *keys = [pending allKeys];
    
    for (NSString *url in keys) {
        ImageDownloader *dl = [pending objectForKey:url];
        
        NSMutableArray *arr = [delegates objectForKey:url];
        if (arr == nil) {
            [pending removeObjectForKey:url];
        }
        else if ([arr count] == 0) {
            [delegates removeObjectForKey:url];
            [pending removeObjectForKey:url];
        }
        else {
            if (dl.requestURL == nil) {
                [dl get:url];
                break;
            }
        }
    }
}


- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	UIImage *image = [UIImage imageWithData:sender.buf];
    
    if (image) {
        image = [self resizeImage:image forURL:sender.requestURL];
        [self insertImage:sender.buf forURL:sender.requestURL];
        image = [self convertImage:image forURL:sender.requestURL];
        
        NSMutableArray *arr = [delegates objectForKey:sender.requestURL];
        if (arr) {
            for (id delegate in arr) {
                if ([delegate respondsToSelector:@selector(profileImageDidGetNewImage:)]) {
                    [delegate performSelector:@selector(profileImageDidGetNewImage:) withObject:image];
                }
            }
            [delegates removeObjectForKey:sender.requestURL];
        }
        [images setObject:image forKey:sender.requestURL];
    }
    
    [self getPendingImage:sender];
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
    [self getPendingImage:sender];
}

- (void)removeDelegate:(id)delegate forURL:(NSString*)key
{
    NSMutableArray *arr = [delegates objectForKey:key];
    if (arr) {
        [arr removeObject:delegate];
        if ([arr count] == 0) {
            [delegates removeObjectForKey:key];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id key in images) {
        UIImage* image = [images objectForKey:key];
        if (image.retainCount == 1) {
            LOG(@"Release image %@", image);
            [array addObject:key];
        }
    }
    [images removeObjectsForKeys:array];
}

- (void)releaseImage:(NSString*)url
{
	UIImage* image = [images objectForKey:url];    
    if (image) {
        [images removeObjectForKey:url];
    }
}

- (UIImage*)getImageFromDB:(NSString*)url
{
    UIImage *image = nil;
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
        image = [UIImage imageWithData:data];
        image = [self resizeImage:image forURL:url];
        image = [self convertImage:image forURL:url];
    }
    [stmt reset];
    
	return image;
}

- (void)insertImage:(NSData*)buf forURL:(NSString*)url
{ 
    static Statement* stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO images VALUES(?, ?, DATETIME('now'))"];
        [stmt retain];
    }
    [stmt bindString:url forIndex:1];
    [stmt bindData:buf forIndex:2];
    
    // Ignore error
    [stmt step];
    [stmt reset];
}

- (UIImage*)resizeImage:(UIImage*)image forURL:(NSString*)url
{
    // Resize image if needed.
    float width  = image.size.width;
    float height = image.size.height;
    // fail safe
    if (width == 0 || height == 0) return image;
    
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

        UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *jpeg = UIImageJPEGRepresentation(image, 0.8);
        [self insertImage:jpeg forURL:url];
        return resized;
    }
    return image;
}

- (UIImage*)convertImage:(UIImage*)image forURL:(NSString*)url
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
    UIImage *converted = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return converted;
}


+(UIImage*)defaultProfileImage:(BOOL)bigger
{
    if (bigger) {
        if (sProfileImage == nil) {
            sProfileImage = [[UIImage imageNamed:@"profileImage.png"] retain];
        }
        return sProfileImage;
    }
    else {
        if (sProfileImageSmall == nil) {
            sProfileImageSmall = [[UIImage imageNamed:@"profileImageSmall.png"] retain];
        }
        return sProfileImageSmall;
    }
}

@end
