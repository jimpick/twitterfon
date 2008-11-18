//
//  FollowInfoView.m
//  TwitterFon
//
//  Created by kaz on 11/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserDetailView.h"


@implementation UserDetailView

@synthesize following;
@synthesize followers;
@synthesize updates;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = false;
    }
    return self;
}


- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (following || followers || updates) {
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
        [[UIColor blackColor] set];
        
        NSString *str;
        str = [NSString stringWithFormat:@"%d", following];
        [str drawInRect:CGRectMake( 20, 2, 70, 21) withFont:[UIFont boldSystemFontOfSize:16]];
        str = [NSString stringWithFormat:@"%d", followers];
        [str drawInRect:CGRectMake(120, 2, 70, 21) withFont:[UIFont boldSystemFontOfSize:16]];
        str = [NSString stringWithFormat:@"%d", updates];
        [str drawInRect:CGRectMake(220, 2, 70, 21) withFont:[UIFont boldSystemFontOfSize:16]];
        
        CGContextSetRGBStrokeColor(context, 0.66, 0.66, 0.66, 1.0);
        CGContextSetLineWidth(context, 1.0);
        CGContextSetAllowsAntialiasing(context, false);
        
        CGContextMoveToPoint(context, 100.0, 3);
        CGContextAddLineToPoint(context, 100.0, 41);
        CGContextStrokePath(context);
        CGContextMoveToPoint(context, 200.0, 3);
        CGContextAddLineToPoint(context, 200.0, 41);
        CGContextStrokePath(context);
        CGContextSetAllowsAntialiasing(context, true);
        
        [[UIColor darkGrayColor] set];
        [@"following" drawInRect:CGRectMake( 20, 24, 70, 22) withFont:[UIFont systemFontOfSize:14]];
        [@"followers" drawInRect:CGRectMake(120, 24, 70, 22) withFont:[UIFont systemFontOfSize:14]];
        [@"updates"   drawInRect:CGRectMake(220, 24, 70, 22) withFont:[UIFont systemFontOfSize:14]];
    }
}


- (void)dealloc {
    [super dealloc];
}


@end
