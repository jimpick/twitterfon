#import <UIKit/UIKit.h>
#import "TFConnection.h"

@interface TwitPicClient : TFConnection
{
}

- (id)initWithTarget:(id)delegate;

- (void)upload:(UIImage*)image;

@end
