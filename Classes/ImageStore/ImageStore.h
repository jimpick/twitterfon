#import <UIKit/UIKit.h>
#import "User.h"
#import "ProfileImage.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
}

- (ProfileImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag delegate:(id)delegate;

- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end
