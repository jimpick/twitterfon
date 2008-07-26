#import <UIKit/UIKit.h>
#import "TFConnection.h"

@interface PostTweet : TFConnection
{
}

- (void)post:(NSString*)tweet;
@end

