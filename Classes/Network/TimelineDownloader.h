#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

@interface TimelineDownloader : TFConnection
{
}

- (void)get:(MessageType)type since:(NSString*)since;

@end
