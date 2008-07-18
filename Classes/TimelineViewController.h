#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "Timeline.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet Timeline*   friendTimeline;
    int                  index;
    NSString*            username;
    BOOL                 loaded;
}

- (void)didSelectViewController:(int)index username:(NSString*)username;

@end
