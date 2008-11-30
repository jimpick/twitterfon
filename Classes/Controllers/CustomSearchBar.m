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

static NSString* sSearchBarPressedImages[3] = {
    @"SearchBarLeftEdgePressed.png",
    @"SearchBarLeftButtonPressed.png",
    @"SearchBarLeftPressed.png",
};

@implementation CustomSearchBar

@synthesize locationButton;
@synthesize distanceButton;
@synthesize text;

- (id)initWithFrame:(CGRect)frame delegate:(id)aDelegate;
{
    if (self = [super initWithFrame:frame]) {

        delegate = aDelegate;
        self.backgroundColor = [UIColor clearColor];
        
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

        left = 0;
        for (int i = 0; i < 3; ++i) {
            layers[i+5] = [CALayer layer];
            UIImage *image = [[UIImage imageNamed:sSearchBarPressedImages[i]] retain];
            CGImageRef imageRef = CGImageRetain([image CGImage]);
            layers[i+5].contents = (id)imageRef;
            layers[i+5].frame = CGRectMake(left, 6, image.size.width, image.size.height);
            left += image.size.width;
            layers[i+5].hidden = true;
            [[self layer] addSublayer:layers[i+5]];
        }
        
        // location button
        locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton setImage:[UIImage imageNamed:@"location_small.png"] forState:UIControlStateNormal];
        [locationButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [locationButton addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchDragExit];
        [locationButton addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:locationButton];

        distanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        distanceButton.font = [UIFont boldSystemFontOfSize:14];
        [distanceButton setTitle:@"" forState:UIControlStateNormal];
        [distanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [distanceButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [distanceButton setTitleShadowOffset:CGSizeMake(0, -1)];
        [distanceButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [distanceButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [distanceButton addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpOutside];
        [distanceButton addTarget:self action:@selector(distanceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:distanceButton];
        distanceButton.hidden = true;

        UIButton *bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookmark setImage:[UIImage imageNamed:@"Bookmarks.png"] forState:UIControlStateNormal];
        [bookmark setImage:[UIImage imageNamed:@"BookmarksPressed.png"] forState:UIControlStateHighlighted];
        [bookmark addTarget:delegate action:@selector(customSearchBarBookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        textField = [[[CustomSearchTextField alloc] initWithFrame:frame] autorelease];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeySearch;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = [UIFont systemFontOfSize:14];
        textField.rightView = bookmark; 
        textField.rightViewMode = UITextFieldViewModeUnlessEditing;
        [self addSubview:textField];

    }
    return self;
}

- (void)layoutLayer
{  
    float leftButtonWidth = (leftButtonExpanded) ? 108 : 18;

    CGRect r = layers[1].frame;
    r.size.width = leftButtonWidth;
    layers[1].frame = r;
    layers[6].frame = r;
    
    r = layers[2].frame;
    r.origin.x = 17 + leftButtonWidth;
    layers[2].frame = r;
    layers[7].frame = r;
    
    r = layers[3].frame;
    r.origin.x = 17 + 16 + leftButtonWidth;
    r.size.width = self.frame.size.width - (17 + 17 + 16 + leftButtonWidth);
    layers[3].frame = r;
    
    r = layers[4].frame;
    r.origin.x = self.frame.size.width - r.size.width;
    layers[4].frame = r;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    float textLeftOffset = 48;
    if (leftButtonExpanded) textLeftOffset += 90;
    
    textField.frame = CGRectMake(textLeftOffset, 14, bounds.size.width - textLeftOffset, 17);

    locationButton.frame = CGRectMake(4, 6, 31, 31);
    distanceButton.frame = CGRectMake(0, 14, 125, 17);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self layoutLayer];
}

- (void)setText:(NSString*)aText
{
    [text release];
    text = [aText retain];
    textField.text = aText;
}

- (void)expandLeftButton:(BOOL)expand
{
    if (expand) {
        locationButton.hidden = true;
        distanceButton.hidden = false;
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    else {
        locationButton.hidden = false;
        distanceButton.hidden = true;
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    leftButtonExpanded = expand;
}

- (void)toggleButton:(BOOL)pressed
{
    for (int i = 0; i < 3; ++i) {
        layers[i].hidden   = pressed;
        layers[i+5].hidden = !pressed;
        [layers[i] removeAllAnimations];
        [layers[i+5] removeAllAnimations];
    }
}

- (void)buttonDown:(id)sender
{
    [self toggleButton:true];
}

- (void)buttonUp:(id)sender
{
    [self toggleButton:false];
}

- (void)locationButtonClicked:(id)sender
{
    [self toggleButton:false];
    
    if ([delegate respondsToSelector:@selector(customSearchBarLocationButtonClicked:)]) {
        [delegate customSearchBarLocationButtonClicked:self];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [self expandLeftButton:true];
    textField.frame = CGRectMake(110 + 48, 14, 90, 17);
    [text release];
    text = [textField.text retain];
    textField.text = @"";
    [self layoutLayer];
    [UIView commitAnimations];
    [textField resignFirstResponder];
}

- (void)distanceButtonClicked:(id)sender
{
    [self toggleButton:false];
    
    if (leftButtonExpanded) {
        if ([delegate respondsToSelector:@selector(customSearchBarDistanceButtonClicked:)]) {
            [delegate customSearchBarDistanceButtonClicked:self];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
    textField.text = text;

    if ([delegate respondsToSelector:@selector(customSearchBarShouldBeginEditing:)]) {
        if (![delegate customSearchBarShouldBeginEditing:self]) {
            return false;
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [self expandLeftButton:false];
    textField.frame = CGRectMake(48, 14, 170, 17);
    [UIView commitAnimations];
    [self layoutLayer];
    
    return true;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
{
    if ([delegate respondsToSelector:@selector(customSearchBarShouldEndEditing:)]) {
        return [delegate customSearchBarShouldEndEditing:self];
    }
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    NSLog(@"%@", aTextField.text);
    [text release];
    text = [aTextField.text retain];
    if ([delegate respondsToSelector:@selector(customSearchBarSearchButtonClicked:)]) {
        [delegate customSearchBarSearchButtonClicked:self];
    }
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textFieldShouldClear:(UITextField *)aTextField
{
    textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    if ([delegate respondsToSelector:@selector(customSearchBar:textDidChange:)]) {
        [delegate customSearchBar:self textDidChange:@""];
    }
    return true;
}

- (BOOL)textField:(UITextField *)aTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [text release];
    text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [text retain];
    if ([text length] == 0) {
        textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    }
    textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    if ([delegate respondsToSelector:@selector(customSearchBar:textDidChange:)]) {
        [delegate customSearchBar:self textDidChange:text];
    }

    return true;
}

- (void) becomeFirstResponder
{
    [textField becomeFirstResponder];
}

- (void) resignFirstResponder
{
    if (!leftButtonExpanded) {
        textField.rightViewMode = UITextFieldViewModeUnlessEditing;
    }
    [textField resignFirstResponder];
}

- (void)drawRect:(CGRect)rect
{
    [self layoutLayer];
   [super drawRect:rect];
}

- (void)dealloc 
{
    [text release];
    [super dealloc];
}


@end
