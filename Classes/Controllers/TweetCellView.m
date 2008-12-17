//
//  TweetCellView.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TweetCellView.h"

@implementation TweetCellView

@synthesize status;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)setStatus:(Status*)value
{
    if (status != value) {
		[status release];
		status = [value retain];
	}
    [super setNeedsDisplay];
}

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
    
    float textFontSize = (status.cellType == TWEET_CELL_TYPE_DETAIL) ? 14 : 13;
    
	[textColor set];
    if (status.cellType == TWEET_CELL_TYPE_NORMAL) {
        [status.user.screenName drawInRect:CGRectMake(0, 0, CELL_WIDTH - DETAIL_BUTTON_WIDTH, TOP) withFont:[UIFont boldSystemFontOfSize:14]];
    }
	[status.text drawInRect:status.textBounds withFont:[UIFont systemFontOfSize:textFontSize]];
	[timestampColor set];
    if (status.cellType != TWEET_CELL_TYPE_NORMAL) {
        NSString *timestamp;
        if ([status.source length]) {
            timestamp = [status.timestamp stringByAppendingFormat:@" from %@", status.source];
        }
        else {
            timestamp = status.timestamp;
        }
        [timestamp drawInRect:CGRectMake(0, status.textBounds.size.height + 3, 250, 16) withFont:[UIFont systemFontOfSize:12]];
    }
    else {
        [status.timestamp drawInRect:CGRectMake(0, TOP + status.textBounds.size.height - 1, 250, 16) withFont:[UIFont systemFontOfSize:12]];
    }
}


- (void)dealloc {
    [status release];
    [super dealloc];
}


@end
