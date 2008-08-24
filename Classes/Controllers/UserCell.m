//
//  UserCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    // name label
    name = [[[UILabel alloc] initWithFrame:CGRectMake(93, 20, 189, 22)] autorelease];
    name.textColor          = [UIColor blackColor];
    name.backgroundColor    = [UIColor clearColor];
    name.font               = [UIFont boldSystemFontOfSize:18];
    [self.contentView addSubview:name];
    
    // numFollowers label
    numFollowers = [[[UILabel alloc] initWithFrame:CGRectMake(93, 39, 217, 21)] autorelease];
    numFollowers.font               = [UIFont systemFontOfSize:13];
    numFollowers.textColor          = [UIColor darkGrayColor];
    numFollowers.backgroundColor    = [UIColor clearColor];
    [self.contentView addSubview:numFollowers];

    
    // location label
    location = [[[UILabel alloc] initWithFrame:CGRectMake(93, 59, 217, 18)] autorelease];
    location.textColor          = [UIColor blackColor];
    location.backgroundColor    = [UIColor clearColor];
    location.font               = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:location];    
    
    // url button
    url = [UIButton buttonWithType:UIButtonTypeCustom];
    url.font                = [UIFont boldSystemFontOfSize:14];
    url.lineBreakMode       = UILineBreakModeTailTruncation;
    url.frame               = CGRectMake(93, 77, 217, 18);
    url.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [url setTitleColor:[UIColor colorWithRed:0.208 green:0.310 blue:0.518 alpha:1.0] forState:UIControlStateNormal];
    [url setTitleColor:[UIColor colorWithRed:0.976 green:0.039 blue:0.071 alpha:1.0] forState:UIControlStateHighlighted];
    [self.contentView addSubview:url];
    
    // protection image
    protected = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    protected.frame = CGRectMake(298, 22, 12, 16);
    [self.contentView addSubview:protected];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

-(void)update:(Message*)message delegate:(id)delegate
{
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
    [url addTarget:delegate action:@selector(didTouchURL:) forControlEvents:UIControlEventTouchUpInside];   
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
 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithRed:0.939 green:0.939 blue:0.939 alpha:1.0];
}

- (void)dealloc {
	[super dealloc];
}


@end
