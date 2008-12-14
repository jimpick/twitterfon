//
//  FriendsTimelineController.h
//  TwitterFon
//
//  Created by kaz on 10/29/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeUtils.h"
#import "TimelineViewDataSource.h"

@interface TimelineViewController : UITableViewController {
    Stopwatch*              stopwatch;
    int                     tab;
    int                     unread;
    BOOL                    isLoaded;
    BOOL                    firstTimeToAppear;
    TimelineViewDataSource* currentDataSource;
    TimelineViewDataSource* timelineDataSource;
    TimelineViewDataSource* sentMessageDataSource;
    CGPoint                 contentOffset;
}

- (void)loadTimeline;
- (void)restoreAndLoadTimeline:(BOOL)load;

- (IBAction)reload:(id)sender;
- (IBAction)segmentDidChange
:(id)sender;

@end
