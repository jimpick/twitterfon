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
    int             since_id;
    int             page;
}

@property (nonatomic, readonly) NSArray* messages;

- (void)getTimeline:(MessageType)type page:(int)page insertAt:(int)row;
- (void)getUserTimeline:(int)user_id page:(int)page insertAt:(int)row;
- (int)restore:(MessageType)type all:(BOOL)flag;
- (void)cancel;

- (int)countMessages;
- (void)appendMessage:(Message*)message;

- (Message*)messageAtIndex:(int)i;
- (Message*)deleteMessageAtIndex:(int)i;
- (void)deleteMessage:(Message*)message;
- (void)insertMessage:(Message*)message;

@end
