//
//  FriendsTimelineController.h
//  TwitterFon
//
//  Created by kaz on 10/29/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeUtils.h"
#import "FriendsTimelineDataSource.h"

@interface FriendsTimelineController : UITableViewController {
    Stopwatch*                  stopwatch;
    int                         tab;
    int                         unread;
    BOOL                        isLoaded;
    BOOL                        firstTimeToAppear;
    FriendsTimelineDataSource*  timelineDataSource;
    CGPoint                     contentOffset;
}

- (void)loadTimeline;
- (void)restoreAndLoadTimeline:(BOOL)load;
- (void)postTweetDidSucceed:(Status*)status;

- (IBAction)reload:(id)sender;

@end
