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

static NSString* sSearchBarImages[5] = {
    @"SearchBarLeftEdge.png",
    @"SearchBarLeftButton.png",
    @"SearchBarLeft.png",
    @"SearchBarBody.png",
    @"SearchBarRight.png",
};

@implementation CustomSearchBar

@synthesize locationButton;
@synthesize leftButtonWidth;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate 
{
    if (self = [super initWithFrame:frame]) {
        
        self.delegate = delegate;

        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.font = [UIFont systemFontOfSize:14];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        
        // location button
        locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton setImage:[UIImage imageNamed:@"location_small.png"] forState:UIControlStateNormal];
        [locationButton addTarget:delegate action:@selector(customSearchBarLocationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        locationButton.frame = CGRectMake(0, 8, 19, 19);
//        [container addSubview:locationButton];

        distanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [distanceButton setTitle:@"within 25 miles" forState:UIControlStateNormal];
        [distanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [distanceButton setTitleShadowOffset:CGSizeMake(0, -1)];
        [distanceButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        distanceButton.frame = CGRectMake(22, 8, 30, 17);
        [container addSubview:distanceButton];
        
        self.leftView = container;
        self.leftViewMode = UITextFieldViewModeAlways;
        leftButtonWidth = [locationButton imageForState:UIControlStateNormal].size.width;
        
        UIButton *bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookmark setImage:[UIImage imageNamed:@"Bookmarks.png"] forState:UIControlStateNormal];
        [bookmark setImage:[UIImage imageNamed:@"BookmarksPressed.png"] forState:UIControlStateHighlighted];
        [bookmark addTarget:delegate action:@selector(customSearchBarBookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightView = bookmark;
        self.rightViewMode = UITextFieldViewModeUnlessEditing;
        
        float left = 0;
        for (int i = 0; i < 5; ++i) {
            layers[i] = [CALayer layer];
            UIImage *image = [[UIImage imageNamed:sSearchBarImages[i]] retain];
            CGImageRef imageRef = CGImageRetain([image CGImage]);
            layers[i].contents = (id)imageRef;
            layers[i].frame = CGRectMake(left, 6, image.size.width, image.size.height);
            left += image.size.width;
            [[self layer] addSublayer:layers[i]];
        }
    }
    return self;
}

- (void)layoutLayer
{    
    CGRect r = layers[1].frame;
    r.size.width = leftButtonWidth;
    layers[1].frame = r;
    
    r = layers[2].frame;
    r.origin.x = 17 + leftButtonWidth;
    layers[2].frame = r;
    
    r = layers[3].frame;
    r.origin.x = 17 + 16 + leftButtonWidth;
    r.size.width = self.frame.size.width - (17 + 17 + 16 + leftButtonWidth);
    layers[3].frame = r;
    
    r = layers[4].frame;
    r.origin.x = self.frame.size.width - r.size.width;
    layers[4].frame = r;
}

- (void)setLeftButtonWidth:(float)value
{
    if (value == 0) {
        leftButtonWidth = [locationButton imageForState:UIControlStateNormal].size.width;
    }
    else {
        leftButtonWidth = value;
    }
    [self layoutLayer];
}

- (void)changeBarSize:(CGRect)rect
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.frame = rect;
    [self layoutLayer];
    [UIView commitAnimations];
   
}

- (void)drawRect:(CGRect)rect
{
    [self layoutLayer];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(44, 14, 136, 17);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(44, 14, 136, 17);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    bounds.origin.x += 0;
    bounds.size.width = [locationButton imageForState:UIControlStateNormal].size.width + 12 * 2;
    return bounds;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 46, 8, 40, 29);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.size.width - 31, 13, 19, 19);
}

- (void)dealloc {
    [inputField autorelease];
    [super dealloc];
}


@end
