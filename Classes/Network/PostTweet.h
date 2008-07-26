#import <UIKit/UIKit.h>
#import "Message.h"

@interface PostTweet : NSObject
{
	NSObject*           delegate;
	NSURLConnection*    conn;
	NSMutableData*      buf;
}

- (id)initWithDelegate:(NSObject*)delegate;
- (void)post:(NSString*)tweet;
@end

