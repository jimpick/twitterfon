#import <UIKit/UIKit.h>
#import "Message.h"

@interface Timeline : NSObject
{
	NSObject*       delegate;
	NSMutableArray* messages;
    MessageType     type;
    int             insertPosition;
    int             since_id;
    int             page;
}

@property (nonatomic, readonly) NSArray* messages;

- (id)initWithDelegate:(id)aDelegate;

- (int)restore:(MessageType)type all:(BOOL)flag;

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
