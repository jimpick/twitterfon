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
        
        // location button
        locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [locationButton setImage:[UIImage imageNamed:@"location_small.png"] forState:UIControlStateNormal];
        [locationButton addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:locationButton];

        distanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        distanceButton.font = [UIFont boldSystemFontOfSize:14];
        [distanceButton setTitle:@"" forState:UIControlStateNormal];
        [distanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [distanceButton setTitleShadowOffset:CGSizeMake(0, -1)];
        [distanceButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [distanceButton addTarget:self action:@selector(distanceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        distanceButton.hidden = true;
        [self addSubview:distanceButton];

        UIButton *bookmark = [UIButton buttonWithType:UIButtonTypeCustom];
        [bookmark setImage:[UIImage imageNamed:@"Bookmarks.png"] forState:UIControlStateNormal];
        [bookmark setImage:[UIImage imageNamed:@"BookmarksPressed.png"] forState:UIControlStateHighlighted];
        [bookmark addTarget:delegate action:@selector(customSearchBarBookmarkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        textField = [[CustomSearchTextField alloc] initWithFrame:frame];
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
    float leftButtonWidth = (leftButtonExpanded) ? 128 : 18;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    float textLeftOffset = 48;
    if (leftButtonExpanded) textLeftOffset += 110;
    
    textField.frame = CGRectMake(textLeftOffset, 14, bounds.size.width - textLeftOffset, 17);

    locationButton.frame = CGRectMake(10, 12, 19, 19);
    distanceButton.frame = CGRectMake(10 + 18, 14, 120, 17);
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
        distanceButton.hidden = false;
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    else {
        distanceButton.hidden = true;
        textField.rightViewMode = UITextFieldViewModeNever;
    }
    leftButtonExpanded = expand;
}

- (void)locationButtonClicked:(id)sender
{

    if ([delegate respondsToSelector:@selector(customSearchBarLocationButtonClicked:)]) {
        [delegate customSearchBarLocationButtonClicked:self];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
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
    if (leftButtonExpanded) {
        if ([delegate respondsToSelector:@selector(customSearchBarDistanceButtonClicked:)]) {
            [delegate customSearchBarDistanceButtonClicked:self];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [self expandLeftButton:false];
    textField.frame = CGRectMake(48, 14, 170, 17);
    [UIView commitAnimations];
    [self layoutLayer];
    
    textField.text = text;

    if ([delegate respondsToSelector:@selector(customSearchBarShouldBeginEditing:)]) {
        return [delegate customSearchBarShouldBeginEditing:self];
    }
    
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

- (void)dealloc {
    [text release];
    [super dealloc];
}


@end
