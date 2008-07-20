//
//  PostViewController.m
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostViewController.h"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(Message*)message;
@end

@implementation PostViewController

@synthesize text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
    charCount.font = [UIFont boldSystemFontOfSize:16];
}

- (IBAction) cancel: (id) sender
{
    [text resignFirstResponder];
    tab.selectedIndex = 1;
}

- (IBAction) send: (id) sender
{
    post = [[PostTweet alloc] initWithDelegate:self];
    [post post:text.text];
    [text resignFirstResponder];
    tab.selectedIndex = 1;
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

- (void)postTweetDidSucceed:(PostTweet*)sender message:(Message*)message
{
    UIViewController *view = [tab.viewControllers objectAtIndex:1];
    if ([view respondsToSelector:@selector(postTweetDidSucceed:)]) {
        [view postTweetDidSucceed:message];
    }      
}

- (void)postTweetDidFail:(PostTweet*)sender error:(NSError*)error
{
    tab.selectedIndex = 0;
}

- (void)setCharCount
{
    int length = [text.text length];
    length = 140 - length;
    if (length == 140) {
        sendButton.enabled = false;
    }
    else if (length < 0) {
        sendButton.enabled = false;
        charCount.textColor = [UIColor redColor];
    }
    else {
        sendButton.enabled = true;
        charCount.textColor = [UIColor whiteColor];
    }
    charCount.text = [NSString stringWithFormat:@"%d", length];    
}

//
// UITextViewDelegate
//
- (void)textViewDidChange:(UITextView *)textView
{
    [self setCharCount];
}

@end
