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
    
    
    rect.size.height = 200;
  	CGContextDrawImage(context, rect, background);
    
    CGContextSetRGBStrokeColor(context, 0.3, 0.3, 0.3, 1.0);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 0.5);
  	CGRect rrect = CGRectMake(10.0, 54.0, 300.0, 138.0);
  	CGFloat radius = 10.0;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
    
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
    
    [super drawRect:rect];
}

- (void)dealloc {
    CGImageRelease(background);
    [super dealloc];
}


@end
