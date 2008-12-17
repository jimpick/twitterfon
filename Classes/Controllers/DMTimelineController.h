//
//  FriendsTimelineController.h
//  TwitterFon
//
//  Created by kaz on 10/29/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tweet;
@class TwitterClient;
@class LoadCell;

@interface DMTimelineController : UITableViewController 
{
    NSMutableArray*         timeline;
    NSMutableDictionary*    messages;
    TwitterClient*          twitterClient;
    LoadCell*               loadCell;
    int                     unread;
    BOOL                    isLoaded;
    BOOL                    firstTimeToAppear;
    BOOL                    isRestored;
    BOOL                    needToGetSentMessage;
    CGPoint                 contentOffset;
}

- (void)loadTimeline;
- (void)restoreAndLoadTimeline:(BOOL)load;
- (void)postTweetDidSucceed:(Tweet*)status;

- (IBAction)reload:(id)sender;

@end
