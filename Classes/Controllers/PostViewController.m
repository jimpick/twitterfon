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

#define kShowAnimationkey   @"showAnimation"
#define kHideAnimationKey   @"hideAnimation"
#define kDeleteAnimationKey @"deletion"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)message;
- (void)postViewAnimationDidFinish:(BOOL)didPost;
@end

@implementation PostViewController

@synthesize navigation;
@synthesize selectedPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    charCount.font      = [UIFont boldSystemFontOfSize:16];
    text.font           = [UIFont systemFontOfSize:18];
    self.view.hidden    = true;
    textRange.location  = 0;
    textRange.length    = 0;
 	text.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"tweet"];
   
    return self;
}

- (void)dealloc 
{
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
    [self startEdit];
}

- (void)startEdit
{
    [navigation.view addSubview:self.view];
    [self setCharCount];
    
    self.view.hidden = false;
    didPost = false;
    [text becomeFirstResponder];
    text.selectedRange = textRange;
    
    CATransition *animation = [CATransition animation];

    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];
    sendButton.enabled = false;

}

- (IBAction) close: (id) sender
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

- (void)cancel: (id)sender
{
    if (connection) {
        [connection cancel];
        [connection autorelease];
        connection = nil;
    }
    [progressWindow hide];
}

- (void)uploadPhoto:(id)sender
{
    float width  = selectedPhoto.size.width;
    float height = selectedPhoto.size.height;
    float scale;
    
    if (width > height) {
        scale = 640 / width;
        height *= scale;
        width = 640;
    }
    else {
        scale = 480 / height;
        width *= scale;
        height = 480;
    }
    
    TwitPicClient *twitpic = [[TwitPicClient alloc] initWithTarget:self];

    if (scale >= 1.0) {
        [twitpic upload:selectedPhoto];
    }
    if (scale < 1.0) {
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [selectedPhoto drawInRect:CGRectMake(0, 0, width, height)];
        UIImage* converted = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [twitpic upload:converted];
    }
    connection = twitpic;
}

- (void)updateStatus
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(postDidSucceed:messages:)];
    
	NSRange r = [text.text rangeOfString:@"d "];
	isDirectMessage = (r.location == 0) ? true : false;
    
	[client post:text.text];
    [progressWindow show];
    connection = client;
}

- (void)updateLocationDidSuccess:(TwitterClient*)sender messages:(NSObject*)messages
{
    latitude = longitude = 0;
    locationButton.style = UIBarButtonItemStyleBordered;
    [sender release];
    connection = nil;
    [self send:self];
}

- (IBAction) updateLocation
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(updateLocationDidSuccess:messages:)];
    
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
    [progressWindow show];
    
    if (latitude != 0 && longitude != 0) {
        [self updateLocation];
    }
    else if (selectedPhoto) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(uploadPhoto:) userInfo:nil repeats:false];
    }
    else {
        [self updateStatus];
    }
}

- (IBAction) clear: (id) sender
{
    [UIView beginAnimations:kDeleteAnimationKey context:self]; 
    
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-80.0, 140.0);
    CGAffineTransform transform3 = CGAffineTransformMakeRotation (0.5);
    
    transform = CGAffineTransformConcat(transform,transform2);
    transform = CGAffineTransformConcat(transform,transform3);
    text.transform = transform;
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:kDeleteAnimationKey]) {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0, 0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0);
    
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        text.transform = transform;
        undoBuffer = text.text;
        text.text = @"";
        charCount.textColor = [UIColor whiteColor];
        sendButton.enabled = false;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];    
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
    if (locationManager == nil) {
        locationManager = [[LocationManager alloc] initWithDelegate:self];    
    }
    if (locationButton.style == UIBarButtonItemStyleDone) {
        locationButton.style = UIBarButtonItemStyleBordered;
        latitude = longitude = 0;
    }
    else {
        [indicator startAnimating];
        [locationManager getCurrentLocation];
        locationButton.enabled = false;
    }
}

- (void)locationManagerDidReceiveLocation:(float)aLatitude longitude:(float)aLongitude
{
    [indicator stopAnimating];
    locationButton.style = UIBarButtonItemStyleDone;
    locationButton.enabled = true;
    latitude  = aLatitude;
    longitude = aLongitude;
}

- (void)locationManagerDidFail
{
    [indicator stopAnimating];
    locationButton.style = UIBarButtonItemStyleBordered;
    locationButton.enabled = true;
}

- (void)postDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj;
{
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
    
    [progressWindow hide];
    
    if (dic && !isDirectMessage) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate postTweetDidSucceed:dic];
    }       
    
    text.text = @"";
    [sender autorelease];
    connection = nil;
    [self close:self];
    didPost = (dic) ? true : false;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:nil
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];    
    [sender autorelease];
    connection = nil;
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
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate postViewAnimationDidFinish:didPost];
    }
}
@end
