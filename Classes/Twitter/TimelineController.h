#import <UIKit/UIKit.h>
#import "Message.h"
#import "TimelineDownloader.h"

@interface TimelineController : NSObject
{
	IBOutlet NSObject* delegate;
	NSMutableArray* messages;
	TimelineDownloader* timelineConn;
}

@property (nonatomic, readonly) NSArray* messages;

- (void)update;

- (int)countMessages;
- (Message*)messageAtIndex:(int)i;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
    
@end
