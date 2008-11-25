//
//  ProfileImageButton.m
//  TwitterFon
//
//  Created by kaz on 11/24/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ProfileImageButton.h"


@implementation ProfileImageButton


- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setImage:(UIImage*)anImage forState:(UIControlState)state
{
    [image release];
    image = [anImage retain];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    float w = image.size.width;
    float h = image.size.height;

    float l = (rect.size.width - w) / 2;
    float t = (rect.size.height  - h) / 2;

    if (w == 48.0) {
        CGContextBeginPath(c);
        CGContextMoveToPoint  (c, l+w, t+h/2);
        CGContextAddArcToPoint(c, l+w, t+h, l+w/2,   t+h, 4);
        CGContextAddArcToPoint(c,   l, t+h,     l, t+h/2, 4);
        CGContextAddArcToPoint(c,   l,   t, l+w/2,     t, 4);
        CGContextAddArcToPoint(c, l+w,   t,   l+w, t+h/2, 4);
        CGContextClosePath(c);
        CGContextClip(c);
    }

    [image drawAtPoint:CGPointMake(l, t)];
    if (self.highlighted) {
        CGContextSetRGBFillColor(c, 0.1, 0.1, 0.1, 0.66);
        CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
        CGContextFillRect(c, CGRectMake(l, t, w, h));
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = true;
    [self setNeedsDisplay];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
   [self setNeedsDisplay];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = false;
    [self setNeedsDisplay];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.highlighted = false;
    [self setNeedsDisplay];
}

- (void)dealloc 
{
    [image release];
    [super dealloc];
}


@end
