//
//  PostViewController.m
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostViewController.h"


#define kAnimationKey @"transitionViewAnimation2"

@implementation PostViewController

@synthesize text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
}

- (IBAction) cancel: (id) sender
{
    [text resignFirstResponder];
    tab.selectedIndex = 1;
}

- (IBAction) send: (id) sender
{
    [text resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [text becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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

- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username
{
    tab = tabBar;
}

- (void)countCharacter
{

}

//
// UITextViewDelegate
//
- (void)textViewDidChange:(UITextView *)textView
{
    int length = [text.text length];
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
