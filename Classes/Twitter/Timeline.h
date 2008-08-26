#import <UIKit/UIKit.h>
#import "Message.h"
#import "TwitterClient.h"

@interface Timeline : NSObject
{
	NSObject*       delegate;
	NSMutableArray* messages;
	TwitterClient*  twitterClient;
    MessageType     type;
    int             insertPosition;
    int             page;
}

@property (nonatomic, readonly) NSArray* messages;

- (void)getTimeline:(MessageType)type page:(int)page insertAt:(int)row;
- (void)getUserTimeline:(int)user_id page:(int)page insertAt:(int)row;
- (int)restore:(MessageType)type;
- (void)cancel;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (void)insertMessage:(Message*)m;

@end
