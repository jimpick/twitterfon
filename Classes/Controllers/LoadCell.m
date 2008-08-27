//
//  UserMessageCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "LoadCell.h"
#import "ColorUtils.h"

@implementation LoadCell

@synthesize spinner;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    // name label
    label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
//    label.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
    label.highlightedTextColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.numberOfLines = 1;
    label.textAlignment = UITextAlignmentCenter;    
    label.frame = CGRectMake(0, 0, 320, 48);
    [self.contentView addSubview:label];
    
    spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.contentView addSubview:spinner];
   
	return self;
}

- (void)setType:(MessageType)type
{
    if (type <= MSG_TYPE_LOAD_FROM_WEB) {
        if (type == MSG_TYPE_LOAD_FROM_WEB) {
            label.text = @"Load more tweets...";
        }
        else {
            label.text = @"Load all stored tweets...";
        }
    }
    else {
        label.text = @"Load this user's timeline...";
    }
    
    CGRect bounds = [label textRectForBounds:CGRectMake(0, 0, 320, 48) limitedToNumberOfLines:1];
    spinner.frame = CGRectMake(bounds.origin.x + bounds.size.width + 4, 16, 16, 16);
    [spinner stopAnimating];
}

- (void)dealloc {
	[super dealloc];
}


@end
