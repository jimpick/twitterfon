//
//  SearchView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OverlayView.h"


@implementation OverlayView

@synthesize searchBar;
@synthesize searchView;
@synthesize mode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.hidden = true;
    
    spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    spinner.frame = CGRectMake(91, 173, 20, 20);
    spinner.hidesWhenStopped = YES;
    [self addSubview:spinner];
    
    searchShadow = [UIImage imageNamed:@"search_shadow.png"];
    return self;
}

- (void)setMode:(OverlayViewMode)aMode
{
    mode = aMode;
    [spinner stopAnimating];
    switch (mode) {
        case OVERLAY_MODE_HIDDEN:
            self.hidden = true;
            break;
            
        case OVERLAY_MODE_DARKEN:
            self.alpha = 0.8;
            self.opaque = false;
            self.hidden = false;
            self.backgroundColor = [UIColor blackColor];
            break;
            
        case OVERLAY_MODE_SHADOW:
            self.backgroundColor = [UIColor clearColor];
            self.opaque = false;
            self.hidden = false;
            self.alpha = 1.0;
            break;
         
    }
    [self setNeedsDisplay];
}

- (void)setMessage:(NSString*)aMessage spinner:(BOOL)flag
{
    [message release];
    message = [aMessage retain];
    if (flag) {
        [spinner startAnimating];
    }
    else {
        [spinner stopAnimating];
    }
    
    mode = OVERLAY_MODE_MESSAGE;

    self.backgroundColor = [UIColor lightGrayColor];
    self.opaque = true;
    self.hidden = false;
    self.alpha = 1.0;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (mode == OVERLAY_MODE_SHADOW) {
        rect.size.height = 13;
        [searchShadow drawInRect:rect];
    }
    else if (mode == OVERLAY_MODE_MESSAGE) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
        [[UIColor colorWithRed:0.2 green:0.2  blue:0.2  alpha:1.0] set];
        CGSize result = 
            [message drawInRect:CGRectMake(0, 173, 320, 20) 
                       withFont:[UIFont boldSystemFontOfSize:16] 
                  lineBreakMode:UILineBreakModeTailTruncation
                      alignment:UITextAlignmentCenter];
        
        CGRect r = spinner.frame;
        r.origin.x = ((320 - result.width) / 2) - 25;
        spinner.frame = r;
    }
    else {
        [super drawRect:rect];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mode == OVERLAY_MODE_SHADOW) {
        [searchView touchesBegan:touches withEvent:event];
    }
    UITouch* t = [touches anyObject];
    point = [t locationInView:self];
    moved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mode == OVERLAY_MODE_SHADOW) {
        [searchView touchesMoved:touches withEvent:event];
    }
    UITouch* t = [touches anyObject];
    CGPoint pt = [t locationInView:self];
    if (point.x != pt.x || point.y != pt.y) {
        moved = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (mode == OVERLAY_MODE_SHADOW) {
        [searchView touchesEnded:touches withEvent:event];
    }

    UITouch* t = [touches anyObject];
    CGPoint pt = [t locationInView:self];
    if (point.x != pt.x || point.y != pt.y) {
        moved = YES;
    }
    
    if (!moved) {
        if (self.mode == OVERLAY_MODE_DARKEN || self.mode == OVERLAY_MODE_SHADOW) {
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionFade];
            [animation setDuration:0.4];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [[self layer] addAnimation:animation forKey:@"fadeout"];
            self.mode = OVERLAY_MODE_HIDDEN;
            [searchBar resignFirstResponder];
        }
    }
}

- (void)dealloc {
    [message release];
    [searchShadow release];
    [super dealloc];
}


@end
