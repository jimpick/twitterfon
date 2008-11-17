//
//  UserCell.h
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"

@interface UserCell : UITableViewCell
{
    UserView*       userView;
}

@property(nonatomic, assign) UserView* userView;

@end
