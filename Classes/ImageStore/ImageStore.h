#import <UIKit/UIKit.h>
#import "User.h"

@interface ImageStore : NSObject
{
	NSMutableDictionary*    images;
    id                      delegate;
}

- (id)initWithDelegate:(id)delegate;

- (UIImage*)getImage:(NSString*)url delegate:(id)aDelegate;
- (void)releaseImage:(NSString*)url;
- (void)didReceiveMemoryWarning;

@end

