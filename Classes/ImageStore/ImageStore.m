#import "ProfileImage.h"
#import "ImageStore.h"
#import "ImageDownloader.h"

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

- (UIImage*)getProfileImage:(User*)user isLarge:(BOOL)isLarge
{
    NSString *url;
    if (isLarge) {
        url = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
    }
    else {
        url = user.profileImageUrl;
    }
    
    return [self getProfileImage:url delegate:user];
}

- (UIImage*)getProfileImage:(NSString*)url delegate:(id)delegate
{
    ProfileImage* profileImage = [images objectForKey:url];
	if (!profileImage) {
        profileImage = [[(ProfileImage*)[ProfileImage alloc] initWithURL:url] autorelease];
        [images setObject:profileImage forKey:url];
    }
    if (profileImage.isLoading) {
        [profileImage addDelegate:delegate];
    }
    return profileImage.image;
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
