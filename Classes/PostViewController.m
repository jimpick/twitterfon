//
//  PostViewController.m
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostViewController.h"
#import "TwitterFonAppDelegate.h"

#define kAnimationKey @"transitionViewAnimation2"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(Message*)message;
- (void)postViewAnimationDidStart;
- (void)postViewAnimationDidFinish:(BOOL)didPost;
- (void)postViewAnimationDidCancel;
@end

@implementation PostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad {
    charCount.font = [UIFont boldSystemFontOfSize:16];
    self.view.hidden = true;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

- (void)startEditWithString:(NSString*)message setDelegate:(id)aDelegate
{
    text.text = [NSString stringWithFormat:@"%@%@", text.text, message];
    [self startEditWithDelegate:aDelegate];
}

- (void)startEditWithDelegate:(id)aDelegate
{
    delegate = aDelegate;
    [self setCharCount];
    self.view.hidden = false;
    didPost = false;
    [text becomeFirstResponder];
    NSRange range = {[text.text length], 0};
    text.selectedRange = range;
}

- (IBAction) cancel: (id) sender
{
    [text resignFirstResponder];
    self.view.hidden = true;
    
	CATransition *animation = [CATransition animation];
  	[animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kAnimationKey];
}

- (IBAction) send: (id) sender
{
    post = [[PostTweet alloc] initWithDelegate:self];
    [post post:text.text];
    sendingWindow.windowLevel = UIWindowLevelAlert;
    [sendingWindow makeKeyAndVisible];
    sendingWindow.label.text = @"Sending...";
    sendingWindow.label.font = [UIFont boldSystemFontOfSize:18];
    [sendingWindow.indicator startAnimating];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [post release];
	[super dealloc];
}

- (void)postTweetDidSucceed:(PostTweet*)sender message:(Message*)message
{
    [sendingWindow resignKeyWindow];
    sendingWindow.hidden = true;
    
    if ([delegate respondsToSelector:@selector(postTweetDidSucceed:)]) {
        [delegate postTweetDidSucceed:message];
    }       
    
    text.text = @"";
    [post autorelease];
    [self cancel:self];
    didPost = true;
}

- (void)postTweetDidFail:(PostTweet*)sender error:(NSError*)error
{
    [sendingWindow.indicator stopAnimating];
    sendingWindow.label.text = @"Failed to send a tweet";
    [post autorelease];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(disableSendingWindow:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)disableSendingWindow:(NSTimer*)timer
{
    [sendingWindow resignKeyWindow];
    sendingWindow.hidden = true;
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

//
// CAAnimationDelegate
//
- (void)animationDidStart:(CAAnimation *)animation
{
	// Inform the delegate if the delegate implements the corresponding method
	if([delegate respondsToSelector:@selector(postViewAnimationDidStart)]) {
		[delegate postViewAnimationDidStart];
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
	    
    [self.view removeFromSuperview];
	
	// Inform the delegate if it implements the corresponding method
	if (finished) {
		if ([delegate respondsToSelector:@selector(postViewAnimationDidFinish:)]) {
			[delegate postViewAnimationDidFinish:didPost];
        }
	}
	else {
		if ([delegate respondsToSelector:@selector(postViewAnimationDidCancel)]) {
			[delegate postViewAnimationDidCancel];
        }
	}
}
@end
