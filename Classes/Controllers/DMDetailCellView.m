//
//  DMDetailCellView.m
//  TwitterFon
//
//  Created by kaz on 1/2/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "DMDetailCellView.h"
#import "TwitterFonAppDelegate.h"
#import "Status.h"

@implementation DMDetailCellView

- (void)didTouchLinkButton:(id)sender
{
    [[TwitterFonAppDelegate getAppDelegate] openLinksViewController:message.text];
}

- (CGFloat)setMessage:(DirectMessage*)value
{
    message = value;
    
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.font = [UIFont systemFontOfSize:14];
    label.text = value.text;
    label.numberOfLines = 20;
    
    CGRect bounds = CGRectMake(0, 0, 280, 200);
    if (message.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        bounds.size.width -= DETAIL_BUTTON_WIDTH;
    }
    
    textBounds = [label textRectForBounds:bounds limitedToNumberOfLines:20];
    
    CGFloat cellHeight = textBounds.size.height + 10 + 16;
    if (cellHeight < 44) {
        cellHeight = 44;
    }
    
    self.frame = CGRectMake(10, 5, 280, textBounds.size.height + 16);
    self.backgroundColor = [UIColor whiteColor];
    
    return cellHeight;
}


- (void)drawRect:(CGRect)rect 
{
    float textFontSize = 14;
    
	[[UIColor blackColor] set];
	[message.text drawInRect:textBounds withFont:[UIFont systemFontOfSize:textFontSize]];
    [[UIColor grayColor] set];
    [message.timestamp drawInRect:CGRectMake(0, textBounds.size.height, 250, 16) withFont:[UIFont systemFontOfSize:12]];
}


- (void)dealloc {
    [super dealloc];
}


@end
