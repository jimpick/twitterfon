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

- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end
