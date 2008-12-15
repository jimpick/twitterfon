#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageCell.h"

@interface Timeline : NSObject
{
	NSMutableArray* messages;
    MessageType     type;
    int             insertPosition;
    int             since_id;
    int             page;
}

@property (nonatomic, readonly) NSArray* messages;

- (id)init;

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

- (int)indexOfObject:(Message*)message;

- (void)updateFavorite:(Message*)message;

- (MessageCell*)getMessageCell:(UITableView*)tableView atIndex:(int)index;

@end
