#import "ProfileImage.h"
#import "ImageStore.h"
#import "ImageDownloader.h"
#import "DebugUtils.h"

#define MAX_CONNECTION 4

@implementation ImageStore

- (id)init
{
	self = [super init];
    images = [[NSMutableDictionary dictionary] retain];
    pendingRequests = [[NSMutableArray array] retain];
    delegates = [[NSMutableDictionary dictionary] retain];    
	return self;
}

- (void)dealloc
{
    [pendingRequests release];
    [delegates release];    
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

- (void)getPendingImage:(NSString*)previousURL
{
    [delegates removeObjectForKey:previousURL];
    [pendingRequests removeObject:previousURL];
    
    if ([pendingRequests count] > 0) {
        NSString *url = [pendingRequests lastObject];
        ImageDownloader* dl = [[ImageDownloader alloc] initWithDelegate:self];
        dl.originalDelegate = [delegates objectForKey:url];
        
        [dl get:url];
        
        [delegates removeObjectForKey:url];        
        [pendingRequests removeLastObject];
    }
}

- (void)requestImage:(NSString*)url delegate:(id)delegate
{
    if ([pendingRequests count] < MAX_CONNECTION) {
        ImageDownloader* dl = [[ImageDownloader alloc] initWithDelegate:self];
        dl.originalDelegate = delegate;
        [dl get:url];
    }
    
    if ([delegates objectForKey:url] == nil) {
        [pendingRequests addObject:url];
        [delegates setObject:delegate forKey:url];    
    }
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
    [sender.originalDelegate imageDownloaderDidSucceed:sender];
    [self getPendingImage:sender.requestURL];
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
    
    [sender.originalDelegate imageDownloaderDidFail:sender error:error];
    [self getPendingImage:sender.requestURL];
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
