#import <UIKit/UIKit.h>
#import "User.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
}

- (UIImage*)getProfileImage:(User*)user isLarge:(BOOL)isLarge;
- (UIImage*)getProfileImage:(NSString*)url delegate:(id)delegate;
- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end

