//
//  UserViewActionCell.h
//  TwitterFon
//
//  Created by kaz on 12/3/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface TweetViewActionCell : UITableViewCell {
    UIButton    *reply, *dm, *retweet;
    Status*     status;
}

@property(nonatomic, assign) Status* status;

@end
