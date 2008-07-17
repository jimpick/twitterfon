//
//  TableViewController.h
//  TwitterPhox
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTimelineController.h"
#import "ImageStore.h"

@interface TableViewController : UITableViewController {
	IBOutlet ImageStore* imageStore;
	IBOutlet FriendTimelineController* friendTimeline;
}

@end
