//
//  UserTimelineCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "LoadCell.h"
#import "ColorUtils.h"

static NSString *sLabels[] = {
    @"Load more people...",
    @"Load more tweets...",
    @"Load all stored tweets...",
    @"Load this user's timeline...",
    @"Loading...",
    @"Send request...",
    @"Follow request has been sent.",
};

@implementation LoadCell

@synthesize spinner;
@synthesize type;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    // name label
    label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor cellLabelColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentCenter;    
    label.frame = CGRectMake(0, 0, 320, 47);
    [self.contentView addSubview:label];
    
    spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.contentView addSubview:spinner];
   
	return self;
}

- (void)setType:(loadCellType)aType
{
    type = aType;
    label.text = sLabels[type];
    [spinner stopAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = [label textRectForBounds:CGRectMake(0, 0, 320, 48) limitedToNumberOfLines:1];
    spinner.frame = CGRectMake(bounds.origin.x + bounds.size.width + 4, (self.frame.size.height / 2) - 8, 16, 16);
    label.frame = CGRectMake(0, 0, 320, self.frame.size.height - 1);
}

- (void)dealloc {
	[super dealloc];
}


@end
