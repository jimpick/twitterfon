//
//  PostViewController.m
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostViewController.h"


#define kAnimationKey @"transitionViewAnimation"

@implementation PostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
    [text becomeFirstResponder];

}

- (IBAction) cancel: (id) sender
{
/*
    //[toolbar removeFromSuperview];
    [charCount removeFromSuperview];
    
	CATransition *animation = [CATransition animation];
	//[animation setDelegate:self];
	
	// Set the type and if appropriate direction of the transition, 
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromBottom];

	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kAnimationKey];
*/
    [text resignFirstResponder];
}

- (IBAction) send: (id) sender
{
    [text resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [text becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

//
// UITextViewDelegate
//
- (void)textViewDidChange:(UITextView *)textView
{
    int length = [textView.text length];
    length = 140 - length;
    if (length < 0) {
        charCount.textColor = [UIColor redColor];
    }
    else {
        charCount.textColor = [UIColor whiteColor];
    }
    charCount.text = [NSString stringWithFormat:@"%d", length];
}

@end
