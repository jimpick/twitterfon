#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"
#import "UserTimelineController.h"

@interface TimelineViewController : UITableViewController {
	Timeline*               timeline;
    UserTimelineController* userTimeline;
    ImageStore*             imageStore;
    NSString*               username;
    int                     tag;
    int                     unread;
}

- (IBAction) post: (id) sender;
- (IBAction) reload: (id) sender;

@end
