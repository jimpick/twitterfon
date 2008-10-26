//
//  UserTimelineController.h
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCell.h"
#import "LoadCell.h"
#import "Message.h"
#import "Timeline.h"
#import "ImageStore.h"

@interface UserTimelineController : UITableViewController {
    IBOutlet UserCell*      userCell;
    ImageStore*             imageStore;
    Message*                message;
    LoadCell*               loadCell;
    Timeline*               timeline;
    int                     indexOfLoadCell;
    NSMutableArray*         deletedMessage;
}

- (void)setMessage:(Message *)message;

@end
