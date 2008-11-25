//
//  UserDetailViewController.h
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"
#import "UserDetailView.h"
#import "TwitterClient.h"

@interface UserDetailViewController : UITableViewController
{
    User*           user;
    UserView*       userView;
    UserDetailView* detailView;
    TwitterClient*  twitterClient;
    
    BOOL            detailLoaded;
    BOOL            followingLoaded;
    BOOL            ownInfo;
}

@property(nonatomic, assign) User* user;
@property(nonatomic, readonly) UserView* userView;

@end
