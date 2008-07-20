#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "Timeline.h"
#include "PostViewController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet Timeline*   friendTimeline;
    UITabBarController*  tab;
    int                  index;
    NSString*            username;
    BOOL                 loaded;
}

- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
