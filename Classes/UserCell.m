//
//  UserCell.m
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserCell.h"


@implementation UserCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidAppear:(BOOL)animated
{

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

	[super setSelected:selected animated:animated];

	// Configure the view for the selected state
}

- (void) initWithMessage:(Message*)m withImage:(UIImage*)image;
{
    name.text = m.user.screenName;
    location.text = @"Tomigaya, Tokyo, Japan";
    [url setTitle:@"http://www.google.com/test/test/test/test/test/test/" forState:UIControlStateNormal];
    [url setTitle:@"http://www.google.com/test/test/test/test/test/test/" forState:UIControlStateHighlighted];
    description.text = m.text;
    profile_image.image = image;    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    name.font           = [UIFont boldSystemFontOfSize:20];
    location.font       = [UIFont systemFontOfSize:14];
    url.font            = [UIFont boldSystemFontOfSize:14];
    url.lineBreakMode   = UILineBreakModeTailTruncation;
    description.font    = [UIFont systemFontOfSize:14];

    description.frame   = [description textRectForBounds:CGRectMake(68, 82, 242, 54) limitedToNumberOfLines:3];    
}


- (void)dealloc {
	[super dealloc];
}


@end
