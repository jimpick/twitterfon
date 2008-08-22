#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TwitterClient : TFConnection
{
}

- (void)get:(MessageType)type since:(NSString*)since userId:(int)user_id;
- (void)post:(NSString*)tweet;

@end
