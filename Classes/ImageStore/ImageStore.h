#import <UIKit/UIKit.h>
#import "User.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
    NSMutableDictionary*    delegates;
	NSMutableDictionary*    pending;
}

- (UIImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag delegate:(id)delegate;

- (void)removeDelegate:(id)delegate forURL:(NSString*)key;

- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end
