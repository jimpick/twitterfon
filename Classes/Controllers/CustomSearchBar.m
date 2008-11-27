//
//  CustomSearchBar.m
//  TwitterFon
//
//  Created by kaz on 11/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomSearchBar.h"
#import "DebugUtils.h"

@implementation CustomSearchBar


- (id)initWithFrame:(CGRect)frame delegate:(id)delegate 
{
    if (self = [super initWithFrame:frame]) {
        
        self.delegate = delegate;

        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.font = [UIFont systemFontOfSize:14];
        
        UIImage *image = [UIImage imageNamed:@"CustomSearchField.png"];
        inputField = [[image stretchableImageWithLeftCapWidth:17 topCapHeight:0] retain];

        // location button
        UIButton *location = [UIButton buttonWithType:UIButtonTypeCustom];
        [location setImage:[UIImage imageNamed:@"location_small.png"] forState:UIControlStateNormal];
        [location addTarget:delegate action:@selector(customSearchBarLocationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.leftView = location;
        self.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton *bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookmark setImage:[UIImage imageNamed:@"Bookmarks.png"] forState:UIControlStateNormal];
        [bookmark setImage:[UIImage imageNamed:@"BookmarksPressed.png"] forState:UIControlStateHighlighted];
        [bookmark addTarget:delegate action:@selector(customSearchBarBookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightView = bookmark;
        self.rightViewMode = UITextFieldViewModeUnlessEditing;
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGRect r= CGRectMake(5, 6, 209, 31);
    [inputField drawInRect:r];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(35, 14, 140, 17);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(35, 14, 150, 17);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    bounds.origin.x += 5;
    bounds.size.width = 37;
    return bounds;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 46, 1 + (bounds.size.height - 29)/2, 40, 29);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 31, (bounds.size.height - 19)/2, 19, 19);
}

- (void)dealloc {
    [inputField autorelease];
    [super dealloc];
}


@end
