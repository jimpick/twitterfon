//
//  DirectMessageCellView.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DirectMessageCellView.h"


@implementation DirectMessageCellView

@synthesize message;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)setMessage:(DirectMessage*)value
{
    if (message != value) {
		[message release];
		message = [value retain];
	}
    [self setNeedsDisplay];
}

#define CELL_WIDTH (320 - 48 - 20 - 20)
#define TOP 16
#define HEIGHT (48 + 3 + 16)

- (void)drawRect:(CGRect)rect
{
    UIColor* textColor;
    UIColor* timestampColor;
    
	UITableViewCell* cell = (UITableViewCell*)self.superview.superview;
	if (cell.selected) {
		textColor       = [UIColor whiteColor];
        timestampColor  = [UIColor lightGrayColor];
	}
	else {
		textColor       = [UIColor blackColor];
        timestampColor  = [UIColor grayColor];
	}
    
    float textFontSize = 13;
    
	[textColor set];
    [message.senderScreenName drawInRect:CGRectMake(0, 3, CELL_WIDTH, TOP) withFont:[UIFont boldSystemFontOfSize:14]];
	[message.text drawInRect:CGRectMake(0, TOP + 3, CELL_WIDTH, 32) withFont:[UIFont systemFontOfSize:textFontSize] lineBreakMode:UILineBreakModeTailTruncation];
	[timestampColor set];
    [message.timestamp drawInRect:CGRectMake(0, TOP + 32 + 1, 250, 13) withFont:[UIFont systemFontOfSize:12]];
}


- (void)dealloc {
    [message release];
    [super dealloc];
}

@end
