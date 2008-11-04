#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TwitPicClient : TFConnection
{
}

- (id)initWithTarget:(id)delegate;

- (void)upload:(UIImage*)image;

@end
