#import <UIKit/UIKit.h>
#import "User.h"

@interface ImageStore : NSObject
{
	IBOutlet NSObject*   delegate;
	NSMutableDictionary* images;
}

- (UIImage*)getImage:(NSString*)url delegate:(id)aDelegate;
- (void)releaseImage:(NSString*)url;

@end
