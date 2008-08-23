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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
	}
    return self;
}

-(CGFloat)calcCellHeight
{
    name.font               = [UIFont boldSystemFontOfSize:18];
    location.font           = [UIFont systemFontOfSize:14];
    url.font                = [UIFont boldSystemFontOfSize:14];
    url.lineBreakMode       = UILineBreakModeTailTruncation;
    numFollowers.font       = [UIFont systemFontOfSize:13];
    numFollowers.textColor  = [UIColor darkGrayColor];
    
    [url addTarget:delegate action:@selector(didTouchURL:) forControlEvents:UIControlEventTouchUpInside];    
    
    name.text               = message.user.name;
    location.text           = message.user.location;
    [url setTitle:message.user.url forState:UIControlStateNormal];
    [url setTitle:message.user.url forState:UIControlStateHighlighted];

    if (message.user.followersCount <= 1) {
        numFollowers.text   = [NSString stringWithFormat:@"%d follower", message.user.followersCount];
    }
    else {
        numFollowers.text   = [NSString stringWithFormat:@"%d followers", message.user.followersCount];
    }
    
    protected.hidden = (message.user.protected) ? false : true;
    
/*    
	description.font        = [UIFont systemFontOfSize:13];
    description.text        = message.user.description;
    description.numberOfLines = 5;
    description.hidden = true;
    CGRect bounds = CGRectMake(93, 93 - 4, 300, 193 - 4);
    description.frame = [description textRectForBounds:bounds limitedToNumberOfLines:5];
    return description.frame.size.height + 93 + 2;
 */
    return 113;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithRed:0.939 green:0.939 blue:0.939 alpha:1.0];
}

- (void)dealloc {
	[message release];

	[super dealloc];
}


@end
