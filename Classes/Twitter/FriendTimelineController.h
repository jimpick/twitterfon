#import <UIKit/UIKit.h>
#import "Message.h"
#import "FriendTimelineDownloader.h"

@interface FriendTimelineController : NSObject
{
	IBOutlet NSObject* delegate;
	NSMutableArray* messages;
	FriendTimelineDownloader* timelineConn;
}

@property (nonatomic, readonly) NSArray* messages;

- (void)update;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
    
@end
