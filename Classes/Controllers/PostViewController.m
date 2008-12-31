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
#import "TwitPicClient.h"
#import "ImageUtils.h"
#import "PostView.h"
#import "REString.h"

#define kShowAnimationkey   @"showAnimation"
#define kHideAnimationKey   @"hideAnimation"

#define GPS_BUTTON_INDEX    2
#define CAMERA_BUTTON_INDEX 3

@implementation PostViewController

@synthesize navigation;
@synthesize selectedPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    text.font           = [UIFont systemFontOfSize:18];
    self.view.hidden    = true;

    textRange.location  = [text.text length];
    textRange.length    = 0;
    
    return self;
}

- (void)dealloc 
{
    [selectedPhoto release];
	[super dealloc];
}

- (void)edit
{
    if (isDirectMessage) {
        self.navigationItem.title = @"Direct message";
    }
    else {
        self.navigationItem.title = @"New tweet";
    }
    [navigation.view addSubview:self.view];
    [postView setCharCount];
    
    [postView setNeedsLayout];
    [postView setNeedsDisplay];
    
    locationButton.enabled = (isDirectMessage) ? false : true;
    
    self.view.hidden = false;
    didPost = false;
    if (isDirectMessage && [recipient.text length] == 0) {
        [recipient becomeFirstResponder];
    }
    else {
        [text becomeFirstResponder];
    }
    text.selectedRange = textRange;
    
    CATransition *animation = [CATransition animation];
 	[animation setDelegate:self];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];
}

- (void)editDirectMessage:(NSString*)aRecipient
{
    isDirectMessage = true;
    [postView editDirectMessage:aRecipient];


    [self edit];
}

- (void)reply:(NSString*)screenName
{
    isDirectMessage = false;
    text.text = [NSString stringWithFormat:@"@%@ %@", screenName, text.text];
    textRange.location = [text.text length];
    textRange.length = 0;

    [self edit];
}

- (void)inReplyTo:(Status*)status
{
    if (status.type == TWEET_TYPE_MESSAGES) {
        [self reply:status.user.screenName];
    }
    else {
        [postView editReply:status];
        [self reply:status.user.screenName];
    }
}

- (void)retweet:(NSString*)status
{
    isDirectMessage = false;
    
    textRange.location = [status length];
    textRange.length = 0;
    text.text = status;
    [postView editRetweet];
    [self edit];
}

- (void)post
{
    isDirectMessage = false;
    [postView editPost];
    [self edit];
}

- (void)editWithURL:(NSString*)URL
{
    isDirectMessage = false;
    if ([TinyURL needToDecode:URL]) {
        TinyURL *encoder = [[TinyURL alloc] initWithDelegate:self];
        [encoder encode:URL];
    }

    // Always append the URL to tail
    NSString *str = [NSString stringWithFormat:@"%@ %@", text.text, URL];
    text.text = str;
    [self edit];
}

- (void)editWithURL:(NSString*)URL title:(NSString*)title
{
    isDirectMessage = false;
    if ([TinyURL needToDecode:URL]) {
        TinyURL *encoder = [[TinyURL alloc] initWithDelegate:self];
        [encoder encode:URL];
    }
    
    // Always append the URL to tail
    NSString *str = [NSString stringWithFormat:@"%@ %@: %@", text.text, title, URL];
    text.text = str;
    [self edit];
}

- (IBAction) close: (id) sender
{
    [recipient resignFirstResponder];
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

- (void)cancel: (id)sender
{
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
    [progressWindow hide];
}

- (void)uploadPhoto
{
    float width  = selectedPhoto.size.width;
    float height = selectedPhoto.size.height;
    float scale;
    
    if (width > height) {
        scale = 640.0 / width;
    }
    else {
        scale = 480.0 / height;
    }
    
    TwitPicClient *twitpic = [[TwitPicClient alloc] initWithTarget:self];

    if (scale >= 1.0) {
        [twitpic upload:selectedPhoto];
    }
    else if (scale < 1.0) {
        [twitpic upload:[selectedPhoto scaleAndRotateImage:640]];
    }
    connection = twitpic;
}

- (void)updateStatus
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(postDidSucceed:obj:)];
   
    if (isDirectMessage) {
        [client send:text.text to:recipient.text];
    }
    else {
        [client post:text.text inReplyTo:postView.inReplyToStatusId];
    }
    [progressWindow show];
    connection = client;
}

- (void)locationManagerDidUpdateLocation:(LocationManager*)manager location:(CLLocation*)location
{
    accuracy.font = [UIFont systemFontOfSize:11];
    float anAccuracy = [location horizontalAccuracy];
    if (anAccuracy > 10000) anAccuracy = 10000;
    accuracy.text = [NSString stringWithFormat:@"+/-%.0lfm", anAccuracy];
}

- (void)updateLocationDidSuccess:(TwitterClient*)sender obj:(NSObject*)obj
{
    connection = nil;
    
    if (sender.hasError) {
        [progressWindow hide];
        [sender alert];
        return;
    }
    
    latitude = longitude = 0;
    locationButton.style = UIBarButtonItemStyleBordered;
    connection = nil;
    [self send:self];
}

- (IBAction) updateLocation
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(updateLocationDidSuccess:obj:)];
    
	[client updateLocation:latitude longitude:longitude];
    [progressWindow show];
    connection = client;
}

- (IBAction) send: (id) sender
{
    int length = [text.text length];
    if (length == 0) {
        sendButton.enabled = false;
        return;
    }
    
    static NSString *nameRegexp = @"^[0-9a-zA-Z_]+$";
    if (isDirectMessage && ![recipient.text matches:nameRegexp withSubstring:nil]) {
        [[TwitterFonAppDelegate getAppDelegate] alert:@"Can't send this message" 
                                              message:@"Recipient's name contains wrong character. Username can only contain letters, numbers and '_'."];
        return;
    }
    
    [progressWindow show];
    
    if (latitude != 0 && longitude != 0) {
        [self updateLocation];
    }
    else if (selectedPhoto) {
        [self performSelector:@selector(uploadPhoto) withObject:nil afterDelay:0.1];
    }
    else {
        [self updateStatus];
    }
}

//
// TwitPicClient delegate
//
- (void)twitPicClientDidPost:(TwitPicClient*)sender mediaId:(NSString*)mediaId
{
    self.selectedPhoto = nil;
    photoButton.style = UIBarButtonItemStyleBordered;

    text.text = [NSString stringWithFormat:@"%@ http://twitpic.com/%@", text.text, mediaId];
    int length = [text.text length];
    if (length > 140) {
        sendButton.enabled = false;
        [progressWindow hide];
    }
    else {
        [self send:self];
    }
    [sender release];
    connection = nil;
}

- (void)twitPicClientDidFail:(TwitPicClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    [[TwitterFonAppDelegate getAppDelegate] alert:error message:detail];
    [sender release];
    connection = nil;
    [progressWindow hide];
}

//
// Friends table
//
- (IBAction) friends:(id)sender
{
    FolloweesViewController *friends = [[[FolloweesViewController alloc] initWithNibName:@"FolloweesView" bundle:nil] autorelease];
    friends.postViewController = self;
    [navigation presentModalViewController:friends animated:true];
}

- (void)friendsViewDidDisappear
{
    text.selectedRange = textRange;
}

- (void)friendsViewDidSelectFriend:(NSString*)screenName
{
    if (screenName) {
        if (recipientIsFirstResponder) {
            recipient.text = screenName;
        }
        else {
            NSMutableString *str = [NSMutableString stringWithString:text.text];
            [str insertString:[NSString stringWithFormat:@"@%@ ", screenName] atIndex:textRange.location];
            textRange.location += [screenName length] + 2;
            textRange.length = 0;
            text.text = str;
        }
        [postView setCharCount];
        [text becomeFirstResponder];    
        text.selectedRange = textRange;
    }
    else {
        if (recipientIsFirstResponder) {
            [recipient becomeFirstResponder];
        }
        else {
            [text becomeFirstResponder];
            text.selectedRange = textRange;
        }
    }
}

//
// Photo Uploading
//
- (void)showImagePicker:(BOOL)hasCamera
{
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
        [as addButtonWithTitle:@"Take Photo"];
    }
    
    [as addButtonWithTitle:@"Choose Existing Photo"];
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
    if ([title isEqualToString:@"Take Photo"]) {
        [self showImagePicker:true];
    }
    else {
        [self showImagePicker:false];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // do nothing here
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    self.selectedPhoto = image;
    photoButton.style = UIBarButtonItemStyleDone;
    [navigation dismissModalViewControllerAnimated:true];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [navigation dismissModalViewControllerAnimated:true];
}

- (void)showKeyboard
{
    [text becomeFirstResponder];
    text.selectedRange = textRange;
}

- (void)imagePickerControllerDidDisappear
{
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
}

//
// Location updating
//
- (IBAction) location:(id)sender
{
    if (locationButton.style == UIBarButtonItemStyleDone) {
        locationButton.style = UIBarButtonItemStyleBordered;
        latitude = longitude = 0;
    }
    else {
        [indicator startAnimating];
        LocationManager* location = [[LocationManager alloc] initWithDelegate:self];    
        [location getCurrentLocation];
        locationButton.enabled = false;
    }
}

- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)location
{
    [indicator stopAnimating];
    locationButton.style = UIBarButtonItemStyleDone;
    locationButton.enabled = true;
    latitude  = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    [manager autorelease];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    [indicator stopAnimating];
    locationButton.style = UIBarButtonItemStyleBordered;
    locationButton.enabled = true;

    [manager autorelease];
}

- (void)postDidSucceed:(TwitterClient*)sender obj:(NSObject*)obj;
{
    [progressWindow hide];
    connection = nil;
    if (sender.hasError) {
        [sender alert];
        return;
    }
    
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
   
    if (dic) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        if (isDirectMessage) {
            [appDelegate sendMessageDidSucceed:dic];
        }
        else {
            [appDelegate postTweetDidSucceed:dic];
        }
    }       
    
    text.text = @"";
    postView.inReplyToStatusId = 0;
    textRange.location = 0;
    textRange.length = 0;
    [self close:self];
    didPost = (dic) ? true : false;
}

- (void)saveTweet
{
    [postView saveTweet];
}

- (void)checkProgressWindowState
{
    if (connection == nil) {
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
    [[TwitterFonAppDelegate getAppDelegate] alert:@"Error encoding TinyURL" message:error];
}

//
// UITextViewDelegate
//
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    textRange = text.selectedRange;
}

- (void)textViewDidChange:(UITextView *)textView
{
    textRange = text.selectedRange;
    [postView setCharCount];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    recipientIsFirstResponder = false;
}

//
// UITextFieldDelegate
//
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    recipientIsFirstResponder = true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([str length] == 0) {
        sendButton.enabled = false;
    }
    else {
        int length = 140 - [text.text length];
        if (length == 140) {
            sendButton.enabled = false;
        }
        else if (length < 0) {
            sendButton.enabled = false;
        }
        else {
            sendButton.enabled = true;
        }
    }
    return true;
}

//
// CAAnimationDelegate
//
- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished 
{
    CATransition *t = (CATransition*)animation;
    if (t.type == kCATransitionMoveIn) {
        sendButton.enabled = false;
    }
    else {
        [self.view removeFromSuperview];
        
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.window makeKeyWindow];
        
        if (finished && didPost) {
            TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate postViewAnimationDidFinish:isDirectMessage];
        }
    }
}
@end
