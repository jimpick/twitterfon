//
//  UserCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserCell.h"


@implementation UserCell

@synthesize message;
@synthesize profileImage;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    return self;
}

-(CGFloat)calcCellHeight
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    name.font               = [UIFont boldSystemFontOfSize:18];
    location.font           = [UIFont systemFontOfSize:14];
    url.font                = [UIFont boldSystemFontOfSize:14];
    url.lineBreakMode       = UILineBreakModeTailTruncation;
    numFollowers.font       = [UIFont systemFontOfSize:13];
    numFollowers.textColor  = [UIColor darkGrayColor];
	description.font        = [UIFont systemFontOfSize:13];
    
    name.text               = message.user.name;
    location.text           = message.user.location;
    [url setTitle:message.user.url forState:UIControlStateNormal];
    [url setTitle:message.user.url forState:UIControlStateHighlighted];
    
    description.text        = message.user.description;
    description.numberOfLines = 5;
    if (message.user.followersCount <= 1) {
        numFollowers.text   = [NSString stringWithFormat:@"%d follower", message.user.followersCount];
    }
    else {
        numFollowers.text   = [NSString stringWithFormat:@"%d followers", message.user.followersCount];
    }
    
    CGRect bounds = CGRectMake(10, 93 - 4, 300, 193 - 4);
    description.frame = [description textRectForBounds:bounds limitedToNumberOfLines:5];
    return description.frame.size.height + 93 + 2;
    
}

- (void)layoutSubviews {

}

- (void)dealloc {
	[message release];

	[super dealloc];
}


@end
