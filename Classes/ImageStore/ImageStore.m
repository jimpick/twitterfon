#import "ProfileImage.h"
#import "ImageStore.h"
#import "ImageDownloader.h"

@interface ImageStore (Private)
- (void)sendRequestForImage:(NSString*)url;
+ (NSMutableDictionary*)getSharedImageStore;
@end

@implementation ImageStore

static NSMutableDictionary* theImageStore = nil;

+ (NSMutableDictionary*)getSharedImageStore
{
    if (theImageStore == nil) {
        theImageStore = [[NSMutableDictionary dictionary] retain];
    }
    return theImageStore;
}

- (id)init
{
	self = [super init];
	images   = [ImageStore getSharedImageStore];
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (UIImage*)getImage:(NSString*)url delegate:(id)aDelegate
{
	ProfileImage* image = [images objectForKey:url];
	if (!image) {  
        image = [[[ProfileImage alloc] initWithURL:url delegate:aDelegate] autorelease];
        [images setObject:image forKey:url];
    }
    return image.image;
}

- (void)releaseImage:(NSString*)url
{
	ProfileImage* image = [images objectForKey:url];    
    if (image) {
        [images removeObjectForKey:url];
    }
}

@end
