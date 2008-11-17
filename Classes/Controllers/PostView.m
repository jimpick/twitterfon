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

- (void)awakeFromNib
{
    UIImage *img = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(img.CGImage);
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    rect.size.height = 460;//: 200;
  	CGContextDrawImage(context, rect, background);
    
    drawRoundedRect(context, CGRectMake(10.0, 54.0, 300.0, 138.0));
    
    [super drawRect:rect];
}

- (void)dealloc {
    CGImageRelease(background);
    [super dealloc];
}


@end
