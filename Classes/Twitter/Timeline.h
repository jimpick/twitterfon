#import <UIKit/UIKit.h>
#import "Message.h"
#import "TwitterClient.h"

@interface Timeline : NSObject
{
	IBOutlet NSObject*  delegate;
	NSMutableArray*     messages;
	TwitterClient*      twitterClient;
    MessageType         type;
}

@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, readonly) NSArray* messages;

- (void)update:(MessageType)type;
- (void)update:(MessageType)type userId:(int)user_id;
- (void)restore:(MessageType)type;
- (void)cancel;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (void)insertMessage:(Message*)m;

@end
