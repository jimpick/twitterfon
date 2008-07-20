#import <UIKit/UIKit.h>
#import "User.h"

@interface ImageStore : NSObject
{
	IBOutlet NSObject*   delegate;
	NSMutableDictionary* images;
}

- (UIImage*)getImage:(User*)user delegate:(id)aDelegate;

@end
