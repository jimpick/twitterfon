//
//  ChatBubbleCell.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ChatBubbleCell.h"
#import "DirectMessage.h"
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

- (void)setMessage:(DirectMessage*)aMessage isOwn:(BOOL)isOwn
{
    message = aMessage;
    self.accessoryType = aMessage.accessoryType;
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator || isOwn) {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [cellView setMessage:aMessage type:isOwn];
    cellView.image = [self getProfileImage:aMessage.senderProfileImageUrl isLarge:false];
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

@end
