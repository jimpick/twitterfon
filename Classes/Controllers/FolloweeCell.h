//
//  FriendCell.h
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Followee.h"

@interface FolloweeCell : UITableViewCell {
	UILabel*    name;
	UILabel*    screenName;
}

- (void)setFollowee:(Followee*)Followee;
- (void)setUser:(User*)user;

@end
