#import "ProfileImage.h"
#import "ImageStore.h"
#import "DebugUtils.h"

#define MAX_CONNECTION 100

static UIImage *sProfileImage = nil;
static UIImage *sProfileImageSmall = nil;

@interface ImageStore(Private)
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
    else {
        ProfileImage *p = [pending objectForKey:url];
        if (!p) {
            p = [[[ProfileImage alloc] initWithURL:url imageStore:self] autorelease];
            if (p.image) {
                [images setObject:p.image forKey:url];
                return p.image;
            }
            [pending setObject:p forKey:url];
        }

        NSMutableArray *arr = [delegates objectForKey:url];
        if (arr) {
            [arr addObject:delegate];
        }
        else {
            [delegates setObject:[NSMutableArray arrayWithObject:delegate] forKey:url];
        }
        if ([pending count] <= MAX_CONNECTION && p.downloader == nil) {
            [p requestImage];
        }
        
        return [ImageStore defaultProfileImage:isLarge];
    }
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

- (void)removeFromQueue:(ProfileImage*)profileImage
{
    NSMutableArray *arr = [delegates objectForKey:profileImage.url];
    if (arr) {
        for (id delegate in arr) {
            if ([delegate respondsToSelector:@selector(profileImageDidGetNewImage:)]) {
                [delegate performSelector:@selector(profileImageDidGetNewImage:) withObject:profileImage.image];
            }
        }
        [delegates removeObjectForKey:profileImage.url];
    }
    [pending removeObjectForKey:profileImage.url];
    [profileImage autorelease];
}

- (void)getPendingImage:(ProfileImage*)profileImage
{
    if (profileImage.image) {
        [images setObject:profileImage.image forKey:profileImage.url];
    }
    
    [self removeFromQueue:profileImage];
    
    NSArray *keys = [pending allKeys];

    for (NSString *url in keys) {
        ProfileImage *p = [pending objectForKey:url];
        
        NSMutableArray *arr = [delegates objectForKey:p.url];
        if (arr == nil) {
            [pending removeObjectForKey:p.url];
        }
        else if ([arr count] == 0) {
            [delegates removeObjectForKey:p.url];
            [pending removeObjectForKey:p.url];
        }
        else {
            if (!p.downloader) {
                [p requestImage];
                break;
            }
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
	ProfileImage* image = [images objectForKey:url];    
    if (image) {
        [images removeObjectForKey:url];
    }
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
