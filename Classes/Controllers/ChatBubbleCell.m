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

@implementation ChatBubbleCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    cellView = [[[ChatBubbleView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:cellView];

	return self;
}

- (void)setMessage:(DirectMessage*)aMessage isOwn:(BOOL)isOwn
{
    self.text = message.text;
    message = aMessage;
    cellView.type = isOwn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    cellView.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [super dealloc];
}

@end
