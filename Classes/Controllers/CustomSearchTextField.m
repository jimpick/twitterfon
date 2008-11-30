//
//  CustomSearchTextField.m
//  TwitterFon
//
//  Created by kaz on 11/27/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "CustomSearchTextField.h"


@implementation CustomSearchTextField

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.placeholder = @"Search";
    }
    return self;
}


- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectOffset(bounds, 0, 7);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectOffset(bounds, 0, 7);
}

#if 0
- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
//    bounds.size.width = (leftButtonExpanded) ? 120 : 18;
    return bounds;
}
- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 16, 6, 19, 19);
}

#endif

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 41, 2, 40, 29);
}


- (void)dealloc {
    [super dealloc];
}


@end
