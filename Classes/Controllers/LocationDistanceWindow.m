//
//  LocationDistanceWindow.m
//  TwitterFon
//
//  Created by kaz on 11/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LocationDistanceWindow.h"
#import "TwitterFonAppDelegate.h"

@implementation LocationDistanceWindow

- (id)initWithDelegate:(id)anDelegate selectedRow:(int)index
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 480)]) {
        
        delegate = anDelegate;
        
        // Initialization code
        self.windowLevel = UIWindowLevelStatusBar;
        self.backgroundColor = [UIColor clearColor];
        
        overlay = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0;
        [self addSubview:overlay];
        
        container = [[[UIView alloc] initWithFrame:CGRectMake(0, 188, 320, 292)] autorelease];
        container.backgroundColor = [UIColor colorWithRed:0.157 green:0.165 blue:0.224 alpha:1.0];
        container.hidden = YES;
        
        picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)] autorelease];
        picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        picker.delegate = self;
        picker.opaque = true;
        picker.showsSelectionIndicator = YES;
        [picker selectRow:index inComponent:0 animated:false];
        
        [container addSubview:picker];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        button.font = [UIFont boldSystemFontOfSize:20];
        button.frame = CGRectMake(20, 228, 280, 52);
        
        UIImage *alertImage = [[UIImage imageNamed:@"distancePickerButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
        [button setBackgroundImage:alertImage forState:UIControlStateNormal];
        
        UIImage *alertImagePressed = [[UIImage imageNamed:@"distancePickerButtonPressed.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
        [button setBackgroundImage:alertImagePressed forState:UIControlStateHighlighted];
        button.adjustsImageWhenHighlighted = false;
        
        [container addSubview:button];

        [self addSubview:container];
    }
    return self;
}

- (void)show
{
    [self makeKeyAndVisible];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    overlay.hidden = NO;
    overlay.alpha = 0.6;
    [UIView commitAnimations];
    
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromTop];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[container layer] addAnimation:animation forKey:@"show"];
    container.hidden = NO;
}

- (void)hide:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    overlay.alpha = 0;
    [UIView commitAnimations];
    
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
  	[animation setDelegate:self];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[container layer] addAnimation:animation forKey:@"hide"];
    container.hidden = YES;
    
    [delegate locationDistanceWindow:self didChangeDistance:[picker selectedRowInComponent:0]];
}

//
// Instance methods
//
static NSString *sDistanceFormat = @"within %d %@%c";
static int sDistances[9] = {1, 2, 5, 10, 25, 50, 100, 250, 500};

+ (NSString*)stringOfDistance:(int)index
{
    BOOL useMetric = [self useMetric];
    NSString *units = useMetric ? @"km" : @"mile";
    
    return [NSString stringWithFormat:sDistanceFormat, sDistances[index], units, (index != 0 && !useMetric) ? 's' : '\0'];
}

+ (int)distanceOf:(int)index
{
    return sDistances[index];
}

+ (BOOL)useMetric
{
    return [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

//
// CAAnimationDelegate
//
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
    [self autorelease];
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window makeKeyWindow];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [LocationDistanceWindow stringOfDistance:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 9;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}



- (void)dealloc {
    [super dealloc];
}


@end
