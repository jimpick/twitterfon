#import <UIKit/UIKit.h>
#import "User.h"
#import "ProfileImage.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
    
    NSMutableArray*         pendingRequests;
    NSMutableDictionary*    delegates;    
}

- (ProfileImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag delegate:(id)delegate;

- (void)requestImage:(NSString*)url delegate:(id)delegate;
- (void)removeFromQueue:(NSString*)url;

- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end
