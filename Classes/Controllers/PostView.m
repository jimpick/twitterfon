//
//  PostView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "PostView.h"


@implementation PostView

- (void)awakeFromNib
{
    UIImage *img = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(img.CGImage);
}


- (void)drawRect:(CGRect)rect {
     CGContextRef context = UIGraphicsGetCurrentContext();
  	CGContextDrawImage(context, rect, background);
}


- (void)dealloc {
    CGImageRelease(background);
    [super dealloc];
}


@end
