//
//  FriendCell.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Followee.h"
#import "FolloweeCell.h"
#import "FolloweeCellView.h"

@implementation FolloweeCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // name label
        cellView = [[[FolloweeCellView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:cellView];
    }
    return self;
}

- (void)dealloc 
{
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect r = self.bounds;
    r.size.height -= 1;
    cellView.frame = r;
}

- (void)setFollowee:(Followee*)followee
{
    cellView.screenName = followee.screenName;
    cellView.name = followee.name;
    [cellView setNeedsDisplay];
    self.image = [self getProfileImage:followee.profileImageUrl isLarge:false];
}

- (void)setUser:(User*)user
{
    cellView.screenName = user.screenName;
    cellView.name = user.name;
    [cellView setNeedsDisplay];
    self.image = [self getProfileImage:user.profileImageUrl isLarge:false];
}

@end
