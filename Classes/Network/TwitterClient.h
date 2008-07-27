#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TwitterClient : TFConnection
{
}

- (void)get:(MessageType)type since:(NSString*)since;
- (void)post:(NSString*)tweet;

@end
