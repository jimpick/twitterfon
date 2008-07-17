#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "FriendTimelineController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet FriendTimelineController* friendTimeline;
}

@end
