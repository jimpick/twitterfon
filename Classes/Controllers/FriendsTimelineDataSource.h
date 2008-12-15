//
//  FriendsTimelineDataSource.h
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TimelineDataSource.h"

@interface FriendsTimelineDataSource : TimelineDataSource <UITableViewDataSource, UITableViewDelegate> {
    UITableViewController*  controller;
    MessageType             messageType;
    int                     insertPosition;
    BOOL                    isRestored;
}

- (id)initWithController:(UITableViewController*)controller messageType:(MessageType)type;
- (void)getTimeline;

@end
