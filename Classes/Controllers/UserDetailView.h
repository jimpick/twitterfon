//
//  FollowInfoView.h
//  TwitterFon
//
//  Created by kaz on 11/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserDetailView : UIView 
{
    User*       user;
}

@property(nonatomic, assign) User* user;

@end
