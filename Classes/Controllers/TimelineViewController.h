#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"
#import "UserTimelineController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore*            imageStore;
	IBOutlet Timeline*              timeline;
    IBOutlet UserTimelineController* userTimeline;
    NSString*                       username;
    int                             tag;
    int                             unread;
}

- (IBAction) post: (id) sender;
- (IBAction) reload: (id) sender;

@end
