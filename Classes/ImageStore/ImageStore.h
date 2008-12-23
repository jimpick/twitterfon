#import <UIKit/UIKit.h>
#import "User.h"
#import "ProfileImage.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
    NSMutableDictionary*    delegates;
	NSMutableDictionary*    pending;
}

- (UIImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag delegate:(id)delegate;

- (void)getPendingImage:(ProfileImage*)profileImage;
- (void)removeFromQueue:(ProfileImage*)profileImage;

- (void)removeDelegate:(id)delegate forURL:(NSString*)key;

- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end
