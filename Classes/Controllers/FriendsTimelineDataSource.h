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
    TweetType               tweetType;
    int                     insertPosition;
    BOOL                    isRestored;
}

- (id)initWithController:(UITableViewController*)controller tweetType:(TweetType)type;
- (void)getTimeline;

@end
