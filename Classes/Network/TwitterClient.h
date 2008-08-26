#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TwitterClient : TFConnection
{
}

- (void)get:(MessageType)type params:(NSDictionary*)params;
- (void)post:(NSString*)tweet;

@end
