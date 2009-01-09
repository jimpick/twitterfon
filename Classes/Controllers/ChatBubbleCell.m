//
//  ChatBubbleCell.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ChatBubbleCell.h"
#import "Tweet.h"
#import "ChatBubbleView.h"
#import "TwitterFonAppDelegate.h"
#import "ColorUtils.h"

@implementation ChatBubbleCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    cellView = [[[ChatBubbleView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:cellView];

    self.target = self;
    self.accessoryAction = @selector(didTouchLinkButton:);
    
	return self;
}

- (void)updateImage:(UIImage*)image
{
    cellView.image = image;
    [cellView setNeedsDisplay];
}

- (void)setMessage:(Tweet*)aMessage type:(BubbleType)type
{
    message = aMessage;
    self.accessoryType = aMessage.accessoryType;
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator || type != BUBBLE_TYPE_GRAY) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;

    [cellView setMessage:aMessage type:type];
    cellView.image = [self getProfileImage:aMessage.user.profileImageUrl isLarge:false];
}

- (void)didTouchLinkButton:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openLinksViewController:message.text];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    cellView.frame = self.bounds;
    self.backgroundColor = [UIColor conversationBackground];
}

- (void)dealloc {
    [super dealloc];
}

+ (CGFloat)calcCellHeight:(Tweet*)msg interval:(int)diff
{
    // Calculate text bounds and cell height here
    //
    CGRect bounds;
    
    bounds = CGRectMake(0, 0, CHAT_BUBBLE_TEXT_WIDTH, 200);
    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:14];
    }
    
    label.text = msg.text;
    CGRect textRect = [label textRectForBounds:bounds limitedToNumberOfLines:10];        
    CGFloat ret = textRect.size.height + 5 + 5 + 5; // bubble height

    if (diff > CHAT_BUBBLE_TIMESTAMP_DIFF) {
        msg.needTimestamp = true;
        ret += 26;
    }
    else {
        msg.needTimestamp = false;
        ret += 5;
    }
    
    return ret;
}

@end
