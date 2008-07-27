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

@property (nonatomic, readonly) NSArray* messages;

- (void)update:(MessageType)type;
- (void)restore:(MessageType)type;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (void)insertMessage:(Message*)m;

@end
