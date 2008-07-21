#import <UIKit/UIKit.h>
#import "ImageStore.h"
#include "Timeline.h"
#include "PostViewController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore* imageStore;
	IBOutlet Timeline*   timeline;
    UITabBarController*  tab;
    NSString*            username;
}

- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;



@end
