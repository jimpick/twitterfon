#import <UIKit/UIKit.h>
#import "ImageStore.h"
#import "Timeline.h"

@interface TimelineViewController : UITableViewController {
    IBOutlet ImageStore*            imageStore;
	IBOutlet Timeline*              timeline;
    NSString*                       username;
    int                             tag;
    int                             unread;
}

- (IBAction) post: (id) sender;
- (IBAction) reload: (id) sender;

@end
