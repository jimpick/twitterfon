#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"
#import "PostViewController.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore*            imageStore;
	IBOutlet Timeline*              timeline;
    NSString*                       username;
    int                             tag;
    int                             unread;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction) post: (id) sender;
- (IBAction) reload: (id) sender;

@end
