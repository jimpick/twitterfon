//
//  FolloweeCellView.m
//  TwitterFon
//
//  Created by kaz on 1/3/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "FolloweeCellView.h"
#import "Followee.h"
#import "Status.h"

@implementation FolloweeCellView

@synthesize screenName;
@synthesize name;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    [screenName drawInRect:CGRectMake(LEFT, 2, CELL_WIDTH, 24) withFont:[UIFont boldSystemFontOfSize:20]];
    [name drawInRect:CGRectMake(LEFT, 28, CELL_WIDTH, 16) withFont:[UIFont systemFontOfSize:14]];
}


- (void)dealloc {
    [super dealloc];
}


@end
