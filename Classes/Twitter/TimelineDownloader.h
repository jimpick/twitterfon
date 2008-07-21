#import <UIKit/UIKit.h>
#import "Message.h"

@interface TimelineDownloader : NSObject
{
	NSObject*           delegate;
	NSURLConnection*    conn;
	NSMutableData*      buf;
    MessageType         type;
}

- (id)initWithDelegate:(NSObject*)delegate;
- (void)get:(MessageType)type since_id:(long)since_id;

@end
