//
//  PostView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "PostView.h"
#import "QuartzUtils.h"

@implementation PostView

@synthesize showRecipient;

- (void)awakeFromNib
{
    UIImage *img = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(img.CGImage);
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    rect.size.height = 460;
    CGContextDrawImage(context, rect, background);
    rect.size.height = 200;
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, rect);
#if 0    
    drawRoundedRect(context, CGRectMake(10.0, 54.0, 300.0, 138.0));
#endif
    if (showRecipient) {
        CGContextSetLineWidth(context, 1);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextSetRGBStrokeColor(context, 0.666, 0.666, 0.666, 1.0);
        CGPoint points[2] = {
            {0, 80}, {320, 80}
        };
        CGContextStrokeLineSegments(context, points, 2);
    }
    
    [super drawRect:rect];
}

- (void)dealloc {
    CGImageRelease(background);
    [super dealloc];
}


@end
