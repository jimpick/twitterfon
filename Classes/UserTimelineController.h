//
//  UserTimeline.h
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCell.h"
#import "Message.h"
#import "ImageStore.h"

@interface UserTimelineController : UITableViewController {
    IBOutlet UserCell*      userCell;
    Message*                message;
    IBOutlet ImageStore*    imageStore;
}

@property(nonatomic, assign) Message *message;

@end
