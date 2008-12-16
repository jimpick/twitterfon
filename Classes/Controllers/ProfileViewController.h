//
//  UserDetailViewController.h
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserView.h"
#import "TwitterClient.h"

@interface ProfileViewController : UITableViewController
{
    User*           user;
    UserView*       userView;
    TwitterClient*  twitterClient;
    
    BOOL            detailLoaded;
    BOOL            followingLoaded;
    BOOL            ownInfo;
}

-(id)initWithProfile:(User*)user;

@end
