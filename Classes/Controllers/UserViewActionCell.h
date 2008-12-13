//
//  UserViewActionCell.h
//  TwitterFon
//
//  Created by kaz on 12/3/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface UserViewActionCell : UITableViewCell {
    UIButton    *reply, *dm, *retweet;
    Message*    message;
}

@property(nonatomic, assign) Message *message;

@end
