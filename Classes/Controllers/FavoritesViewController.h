//
//  FavoritesViewController.h
//  TwitterFon
//
//  Created by kaz on 1/3/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineDataSource.h"

@class TwitterClient;
@class Timeline;

@interface FavoritesViewController : UITableViewController
{
    Timeline*           timeline;
    LoadCell*           loadCell;
    CGPoint             contentOffset;
    TwitterClient*      twitterClient;
    NSString*           screenName;
    BOOL                isRestored;
}

- (void)loadTimeline:(NSString*)screenName;
- (int)restore:(BOOL)all;

- (IBAction)reload:(id)sender;

@end
