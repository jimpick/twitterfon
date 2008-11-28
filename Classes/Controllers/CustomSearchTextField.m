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

#if 0
- (CGRect)textRectForBounds:(CGRect)bounds
{
        return CGRectMake(44, 14, 136, 17);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(44, 14, bounds.size.width - 84, 17);
}

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
    return CGRectMake(bounds.size.width - 40, -6, 40, 29);
}


- (void)dealloc {
    [super dealloc];
}


@end
