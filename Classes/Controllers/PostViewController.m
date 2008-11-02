//
//  PostViewController.m
//  TwitterFon
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PostViewController.h"
#import "TwitterFonAppDelegate.h"
#import "FolloweesViewController.h"
#import "PostImagePickerController.h"
#import "TinyURL.h"

#define kShowAnimationkey @"showAnimation"
#define kHideAnimationKey @"hideAnimation"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)message;
- (void)postViewAnimationDidFinish:(BOOL)didPost;
@end

@implementation PostViewController

@synthesize appDelegate;
@synthesize navigation;
@synthesize selectedPhoto;

- (void)viewDidLoad
{
    charCount.font      = [UIFont boldSystemFontOfSize:16];
    text.font           = [UIFont systemFontOfSize:18];
    self.view.hidden    = true;
    textRange.location  = 0;
    textRange.length    = 0;
 	text.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"tweet"];
}

- (void)dealloc 
{
    [post release];
	[super dealloc];
}

- (void)startEditWithString:(NSString*)message
{
    NSMutableString *str = [NSMutableString stringWithString:text.text];
    [str insertString:message atIndex:textRange.location];
    textRange.location += [message length];

    self.view.hidden = false;
    textRange.length = 0;
    text.text = str;
    [text becomeFirstResponder];
    text.selectedRange = textRange;
    [self startEdit];
}

- (void)startEditWithURL:(NSString*)URL
{
    if ([TinyURL needToDecode:URL]) {
        TinyURL *encoder = [[TinyURL alloc] initWithDelegate:self];
        [encoder encode:URL];
    }

    // Always append the URL to tail
    NSString *str = [NSString stringWithFormat:@"%@ %@", text.text, URL];
    
    self.view.hidden = false;
    textRange.length = 0;
    text.text = str;
    [text becomeFirstResponder];
    text.selectedRange = textRange;
    [self startEdit];
}

- (void)startEdit
{
    [navigation.view addSubview:self.view];
    [self setCharCount];
    self.view.hidden = false;
    didPost = false;
    [text becomeFirstResponder];

    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];
    sendButton.enabled = false;

}

- (IBAction) cancel: (id) sender
{
    textRange = text.selectedRange;
    [text resignFirstResponder];
    self.view.hidden = true;
    
	CATransition *animation = [CATransition animation];
  	[animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[self.view layer] addAnimation:animation forKey:kHideAnimationKey];
}

- (IBAction) send: (id) sender
{
    int length = [text.text length];
    if (length == 0) {
        sendButton.enabled = false;
        return;
    }
    
    post = [[TwitterClient alloc] initWithTarget:self action:@selector(postDidSucceed:messages:)];

	NSRange r = [text.text rangeOfString:@"d "];
	isDirectMessage = (r.location == 0) ? true : false;

	[post post:text.text];
    [progressWindow show];
}

- (IBAction) clear: (id) sender
{
    text.text = @"";
    sendButton.enabled = false;
}

//
// Friends table
//
- (IBAction) friends:(id)sender
{
    FolloweesViewController *friends = [[[FolloweesViewController alloc] initWithNibName:@"FriendsView" bundle:nil] autorelease];
    friends.postViewController = self;
    textRange = text.selectedRange;
    [navigation presentModalViewController:friends animated:true];
}

- (void)friendsViewDidDisappear
{
    text.selectedRange = textRange;
}

- (void)friendsViewDidSelectFriend:(NSString*)screenName
{
    if (screenName) {
        NSMutableString *str = [NSMutableString stringWithString:text.text];
        [str insertString:[NSString stringWithFormat:@"@%@ ", screenName] atIndex:textRange.location];
        textRange.location += [screenName length] + 2;
        textRange.length = 0;
        text.text = str;
    }
    [text becomeFirstResponder];    
    text.selectedRange = textRange;
}

//
// Photo Uploading
//
- (void)showImagePicker:(BOOL)hasCamera
{
    textRange = text.selectedRange;
    PostImagePickerController *picker = [[[PostImagePickerController alloc] init] autorelease];
    picker.postViewController = self;
    picker.delegate = self;
    if (hasCamera) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    [navigation presentModalViewController:picker animated:YES];
    
}

- (IBAction) photos:(id)sender
{
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (selectedPhoto == nil && hasCamera == false) {
        [self showImagePicker:false];
        return;
    }
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:nil];
    
    if (selectedPhoto) {
        [as addButtonWithTitle:@"Clear Current Selection"];
        as.destructiveButtonIndex = [as numberOfButtons] - 1;
    }
    
    if (hasCamera) {
        [as addButtonWithTitle:(selectedPhoto) ? @"Take Another Photo" : @"Take Photo"];
    }
    
    [as addButtonWithTitle:(selectedPhoto) ? @"Choose Another Photo" : @"Choose Existing Photo"];
    [as addButtonWithTitle:@"Cancel"];
    as.cancelButtonIndex = [as numberOfButtons] - 1;
    
    [as showInView:navigation.parentViewController.view];
    [as release];
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }
    else if (as.destructiveButtonIndex == buttonIndex) {
        self.selectedPhoto = nil;
        photoButton.style = UIBarButtonItemStyleBordered;
        return;
    }
    
    NSString *title = [as buttonTitleAtIndex:buttonIndex];
    if ([title compare:@"Take Photo"] == NSOrderedSame) {
        [self showImagePicker:true];
    }
    else {
        [self showImagePicker:false];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.selectedPhoto = image;
    photoButton.style = UIBarButtonItemStyleDone;
    [navigation dismissModalViewControllerAnimated:true];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [navigation dismissModalViewControllerAnimated:true];
}

- (void)showKeyboard:(NSTimer*)timer
{
    [text becomeFirstResponder];
}

- (void)imagePickerControllerDidDisappear
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showKeyboard:) userInfo:nil repeats:NO];
}

//
// Location updating
//
- (IBAction) location:(id)sender
{
}


- (void)postDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj;
{
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
    
    [progressWindow hide];
    
    if (dic && !isDirectMessage) {
        [appDelegate postTweetDidSucceed:dic];
    }       
    
    text.text = @"";
    [post autorelease];
    post = nil;
    [self cancel:self];
    didPost = (dic) ? true : false;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];    
    [post autorelease];
    post = nil;
    [progressWindow hide];
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

- (void)saveTweet
{
    [[NSUserDefaults standardUserDefaults] setObject:text.text forKey:@"tweet"];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)checkProgressWindowState
{
    if (post == nil) {
        [progressWindow hide];
    }
}

//
// TinyURLDelegate
//
- (void)encodeTinyURLDidSucceed:(NSString*)tinyURL URL:(NSString*)URL
{
    NSRange r = [text.text rangeOfString:URL];
    if (r.location != NSNotFound) {
        NSMutableString *str = [NSMutableString stringWithString:text.text];
        [str replaceCharactersInRange:r withString:tinyURL];
        text.text = str;
        if (--r.location < 0) r.location = 0;
        r.length = 0;
        text.selectedRange = r;
    }
}

- (void)tinyURLDidFail:(TinyURL*)sender error:(NSString*)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TinyURL error"
                                                    message:error
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
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
        [appDelegate postViewAnimationDidFinish:didPost];
    }

}
@end
