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

- (void)didReceiveMemoryWarning
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id key in images) {
	ProfileImage* image = [images objectForKey:key];        
        if (image.image.retainCount == 1) {
            [array addObject:key];
        }
    }
    [images removeObjectsForKeys:array];
}

- (void)releaseImage:(NSString*)url
{
	ProfileImage* image = [images objectForKey:url];    
    if (image) {
        [images removeObjectForKey:url];
    }
}

@end
