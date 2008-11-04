#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TwitPicClient : TFConnection
{
    id          context;
    SEL         action;
}

@property(nonatomic, assign) id context;

- (id)initWithTarget:(id)delegate action:(SEL)action;

- (void)upload:(UIImage*)image;

@end
