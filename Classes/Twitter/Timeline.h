#import <UIKit/UIKit.h>
#import "Message.h"
#import "TwitterClient.h"

@interface Timeline : NSObject
{
	NSObject*       delegate;
	NSMutableArray* messages;
	TwitterClient*  twitterClient;
    MessageType     type;
    NSString*       lastMessageDate;
    int             insertPosition;
}

@property (nonatomic, readonly) NSArray* messages;

- (void)update:(MessageType)type;
- (void)update:(MessageType)type page:(int)page insertAt:(int)row;
- (void)update:(MessageType)type userId:(int)user_id;
- (int)restore:(MessageType)type;
- (void)cancel;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (void)insertMessage:(Message*)m;

@end
