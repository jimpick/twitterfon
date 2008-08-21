//
//  UserMessageCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserMessageCell.h"

@implementation UserMessageCell

@synthesize message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    // text label
    textLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    textLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:textLabel];
    
    // timestamp label
    timestamp = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    timestamp.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:timestamp];

	return self;
}

-(void)setType:(UserCellType)aType
{
    type = aType;
    if (type == USER_CELL_NORMAL) {
        textLabel.textColor = [UIColor blackColor];        
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.numberOfLines = 10;
        textLabel.textAlignment = UITextAlignmentLeft;
        textLabel.contentMode = UIViewContentModeTopLeft;
        
        timestamp.font = [UIFont systemFontOfSize:12];
        timestamp.textAlignment = UITextAlignmentRight;
        timestamp.frame = CGRectMake(LEFT, 0, CELL_WIDTH - DETAIL_BUTTON_WIDTH, TOP);
        
        self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        button.frame = CGRectMake(288, 0, 22, 22);
        [button setImage:[[UIImage imageNamed:@"favorited.png"] retain] forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(didTouchAccessory:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;        
    }
    else {
        textLabel.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
        textLabel.highlightedTextColor = [UIColor whiteColor];
        textLabel.font = [UIFont boldSystemFontOfSize:16];
        textLabel.numberOfLines = 1;
        textLabel.textAlignment = UITextAlignmentCenter;
       
        timestamp.font = [UIFont systemFontOfSize:12];
        timestamp.textAlignment = UITextAlignmentCenter;
        timestamp.frame = CGRectMake(LEFT, 16, CELL_WIDTH - DETAIL_BUTTON_WIDTH, TOP);
    }
}

- (void)layoutSubviews {
    
	[super layoutSubviews];

    if (type == USER_CELL_NORMAL) {
        textLabel.text = message.text;
        timestamp.text = @"1 hour ago";
    
        CGRect r = [textLabel textRectForBounds:CGRectMake(10, 10, 280, 128) limitedToNumberOfLines:10];
        textLabel.frame = r;
        timestamp.frame = CGRectMake(10, 10 + r.size.height, 280, 16);
        timestamp.hidden = false;
        self.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        textLabel.frame = CGRectMake(10, 16, 290, 16);        
        textLabel.text = @"Load this user's timeline...";
        timestamp.hidden = true;
        self.accessoryType  = UITableViewCellAccessoryNone;       
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }

}


- (void)dealloc {
	[super dealloc];
}


@end
