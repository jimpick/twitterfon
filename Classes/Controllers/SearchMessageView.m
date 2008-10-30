//
//  SearchView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SearchMessageView.h"

@implementation SearchMessageView

@synthesize searchBar;

- (void)setMessage:(NSString*)message indicator:(BOOL)indicator
{
    messageLabel.text = message;
    messageIndicator.hidden = (indicator) ? false : true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	UITouch* t = [touches anyObject];
	point = [t locationInView:self];
	moved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
    
	UITouch* t = [touches anyObject];
	CGPoint pt = [t locationInView:self];
	if (point.x != pt.x || point.y != pt.y) {
		moved = YES;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
    
	UITouch* t = [touches anyObject];
	CGPoint pt = [t locationInView:self];
	if (point.x != pt.x || point.y != pt.y) {
		moved = YES;
	}
	
	if (!moved) {
        if ([searchBar isFirstResponder]) {
            [searchBar resignFirstResponder];
        }
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
