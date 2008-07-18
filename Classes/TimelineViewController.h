#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "TimelineController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet TimelineController* friendTimeline;
}

@end
