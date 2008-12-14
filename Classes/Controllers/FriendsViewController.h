//
//  FriendsViewController.h
//  TwitterFon
//
//  Created by kaz on 12/12/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadCell.h"
#import "TwitterClient.h"
#import "ImageStore.h"

@interface FriendsViewController : UITableViewController {
    NSString*           screenName;
    NSMutableArray*     friends;
    BOOL                isFollowers;
    BOOL                hasMore;
    int                 page;
    LoadCell*           loadCell;
    TwitterClient*      twitterClient;
    ImageStore*         imageStore;
}

- (id)initWithScreenName:(NSString*)screenName isFollowers:(BOOL)isFollowers;

@end
