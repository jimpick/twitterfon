#import <UIKit/UIKit.h>

@interface ImageStore : NSObject
{
	IBOutlet NSObject* delegate;
	NSMutableDictionary* images;
	NSMutableDictionary* conns;
}

- (UIImage*)getImage:(NSString*)url;

@end
