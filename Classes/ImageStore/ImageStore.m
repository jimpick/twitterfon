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

- (UIImage*)getImage:(User*)user delegate:(id)aDelegate
{
	ProfileImage* image = [images objectForKey:user.profileImageUrl];
	if (!image) {  
        image = [[[ProfileImage alloc] initWithUser:user delegate:aDelegate] autorelease];
        [images setObject:image forKey:user.profileImageUrl];
    }
    return image.image;
}

@end
