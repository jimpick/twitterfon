#import "ProfileImage.h"
#import "ImageStore.h"
#import "ImageDownloader.h"

@implementation ImageStore

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
    images = [[NSMutableDictionary dictionary] retain];
    delegate = aDelegate;
	return self;
}

- (void)dealloc
{
    [images release];
	[super dealloc];
}

- (UIImage*)getImage:(NSString*)url delegate:(id)aDelegate
{
	ProfileImage* image = [images objectForKey:url];
	if (!image) {  
        image = [[[ProfileImage alloc] initWithURL:url appDelegate:delegate delegate:aDelegate] autorelease];
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
