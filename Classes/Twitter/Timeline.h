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

- (id)initWithDelegate:(id)aDelegate;

- (int)restore:(MessageType)type all:(BOOL)flag;
- (void)cancel;


- (int)countMessages;
- (void)appendMessage:(Message*)message;
- (void)insertMessage:(Message*)message atIndex:(int)index;

- (Message*)messageAtIndex:(int)i;
- (Message*)messageById:(sqlite_int64)id;
- (Message*)lastMessage;

- (void)removeMessage:(Message*)message;
- (void)removeMessageAtIndex:(int)index;
- (void)removeLastMessage;
- (void)removeAllMessages;

- (void)updateFavorite:(Message*)message;

@end
