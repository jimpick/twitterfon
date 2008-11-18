//
//  FollowInfoView.h
//  TwitterFon
//
//  Created by kaz on 11/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserDetailView : UIView 
{
    int         following;
    int         followers;
    int         updates;
}

@property(nonatomic, assign) int following;
@property(nonatomic, assign) int followers;
@property(nonatomic, assign) int updates;

@end
