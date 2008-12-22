#import "ProfileImage.h"
#import "ImageStore.h"
#import "ImageDownloader.h"
#import "DebugUtils.h"

@implementation ImageStore

- (id)init
{
	self = [super init];
    images = [[NSMutableDictionary dictionary] retain];
	return self;
}

- (void)dealloc
{
    [images release];
	[super dealloc];
}

- (ProfileImage*)getProfileImage:(NSString*)anURL isLarge:(BOOL)isLarge delegate:(id)delegate
{
    NSString *url;
    if (isLarge) {
        url = [anURL stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
    }
    else {
        url = anURL;    
    }        
    
    ProfileImage* profileImage = [images objectForKey:url];
	if (!profileImage) {
        profileImage = [[(ProfileImage*)[ProfileImage alloc] initWithURL:url] autorelease];
        [images setObject:profileImage forKey:url];
    }
    if (profileImage.isLoading) {
        [profileImage addDelegate:delegate];
    }
    return profileImage;
}

- (void)didReceiveMemoryWarning
{
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    for (id key in images) {
	ProfileImage* image = [images objectForKey:key];        
        if (image.image.retainCount == 1) {
            LOG(@"Release image %@", image.image);
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
