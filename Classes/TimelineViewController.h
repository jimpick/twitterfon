#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "Timeline.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet Timeline*   friendTimeline;
    int                  index;
}

- (void)didSelectViewController:(int)index;

@end
