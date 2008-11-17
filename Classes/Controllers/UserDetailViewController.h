//
//  UserDetailViewController.h
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"
#import "FollowInfoView.h"
#import "TwitterClient.h"

@interface UserDetailViewController : UITableViewController
{
    User*           user;
    UserView*       userView;
    FollowInfoView* followInfo;
    UILabel*        description;
    UILabel*        followStatus;
    TwitterClient*  twitterClient;
    
    BOOL            detailLoaded;
    BOOL            following;
    BOOL            ownInfo;
}

@property(nonatomic, assign) User* user;
@property(nonatomic, assign) UserView* userView;

@end
