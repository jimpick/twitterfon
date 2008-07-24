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

#define kShowAnimationkey @"showAnimation"
#define kHideAnimationKey @"hideAnimation"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(Message*)message;
- (void)postViewAnimationDidFinish:(BOOL)didPost;
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
    text.font = [UIFont systemFontOfSize:16];
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

- (void)startEditWithString:(NSString*)message insertAfter:(BOOL)insertAfter setDelegate:(id)aDelegate
{
    NSRange range;
    if (insertAfter) {
        range.location = [text.text length];
    }
    text.text = [NSString stringWithFormat:@"%@%@", text.text, message];
    
    if (!insertAfter) {
        range.location = [text.text length];
    }

    self.view.hidden = false;
    range.length = 0;
    [text becomeFirstResponder];
    text.selectedRange = range;
    [self startEditWithDelegate:aDelegate];
}

- (void)startEditWithDelegate:(id)aDelegate
{
    delegate = aDelegate;
    [self setCharCount];
    self.view.hidden = false;
    didPost = false;
    [text becomeFirstResponder];

    CATransition *animation = [CATransition animation];
//    [animation setDelegate:self];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.5];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];

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
	
	[[self.view layer] addAnimation:animation forKey:kHideAnimationKey];
}

- (IBAction) send: (id) sender
{
    post = [[PostTweet alloc] initWithDelegate:self];
    [post post:text.text];
    [sendingWindow show];
}

- (IBAction) clear: (id) sender
{
    text.text = @"";
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
    [sendingWindow hide];
    
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
    [sendingWindow fail];
    [post autorelease];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:sendingWindow selector:@selector(hide) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
    [self.view removeFromSuperview];
	
    if (finished) {
        if ([delegate respondsToSelector:@selector(postViewAnimationDidFinish:)]) {
            [delegate postViewAnimationDidFinish:didPost];
        }
    }

}
@end
