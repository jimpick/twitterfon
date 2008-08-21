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

        name.font = [UIFont boldSystemFontOfSize:18];
        location.font = [UIFont systemFontOfSize:14];
        url.font = [UIFont boldSystemFontOfSize:14];
        numFollowers.font = [UIFont systemFontOfSize:12];
        numFollowers.textColor = [UIColor darkGrayColor];
        description.numberOfLines = 2;
        description.font = [UIFont systemFontOfSize:12];
	}
    return self;
}

- (void)layoutSubviews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    name.font = [UIFont boldSystemFontOfSize:18];
    location.font = [UIFont systemFontOfSize:14];
    url.font = [UIFont boldSystemFontOfSize:14];
    numFollowers.font = [UIFont systemFontOfSize:12];
    numFollowers.textColor = [UIColor darkGrayColor];
    description.numberOfLines = 2;
	description.font = [UIFont systemFontOfSize:12];

    name.text        = message.user.name;
    location.text    = message.user.location;
    [url setTitle:message.user.url forState:UIControlStateNormal];
    [url setTitle:message.user.url forState:UIControlStateHighlighted];
    description.text = message.user.description;
}

- (void)dealloc {
	[message release];

	[super dealloc];
}


@end
