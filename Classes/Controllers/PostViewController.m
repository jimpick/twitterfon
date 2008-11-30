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
#define kDeleteAnimationKey @"deleteAnimation"
#define kUndoAnimationKey   @"undoAnimation"

#define DELETE_BUTTON_INDEX 0
#define GPS_BUTTON_INDEX    2
#define CAMERA_BUTTON_INDEX 3

@interface PostViewController (Private)
- (void)edit;
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
 	text.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"tweet"];
    textRange.location  = [text.text length];
    textRange.length    = 0;
    
    recipient.font = [UIFont systemFontOfSize:16];
    
    return self;
}

- (void)dealloc 
{
    [selectedPhoto release];
	[super dealloc];
}

- (void)editDirectMessage:(NSString*)aRecipient
{
    isDirectMessage = true;
    recipient.text = aRecipient;
    if (aRecipient) {
        recipient.enabled = false;
        recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
    else {
        recipient.enabled = true;
        recipient.textColor = [UIColor blackColor];
    }
    [self edit];
}

- (void)editWithString:(NSString*)message
{
    isDirectMessage = false;
    if (message) {
        NSMutableString *str = [NSMutableString stringWithString:text.text];
        [str insertString:message atIndex:textRange.location];
        textRange.location += [message length];
        textRange.length = 0;
        text.text = str;
    }
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

- (void)edit
{
    [navigation.view addSubview:self.view];
    [self setCharCount];
    PostView* view = (PostView*)self.view;
    
    if (isDirectMessage) {
        self.navigationItem.title = @"Direct message";
        to.hidden = false;
        recipient.hidden = false;
        view.showRecipient = true;
        [view setNeedsDisplay];
        text.frame = CGRectMake(5, 88, 310, 112);
    }
    else {
        self.navigationItem.title = @"Post";
        to.hidden = true;
        recipient.hidden = true;
        view.showRecipient = false;
        [view setNeedsDisplay];
        text.frame = CGRectMake(5, 49, 310, 156);
    }
    
    locationButton.enabled = (isDirectMessage) ? false : true;
    
    self.view.hidden = false;
    didPost = false;
    if (isDirectMessage && recipient.text == nil) {
        [recipient becomeFirstResponder];
    }
    else {
        [text becomeFirstResponder];
    }
    text.selectedRange = textRange;
    
    CATransition *animation = [CATransition animation];

    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setDuration:0.25];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.view layer] addAnimation:animation forKey:kShowAnimationkey];
    sendButton.enabled = false;

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
	[animation setDuration:0.25];
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
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(postDidSucceed:messages:)];
   
    if (isDirectMessage) {
        [client send:text.text to:recipient.text];
    }
    else {
        [client post:text.text];
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

- (void)updateLocationDidSuccess:(TwitterClient*)sender messages:(NSObject*)messages
{
    latitude = longitude = 0;
    locationButton.style = UIBarButtonItemStyleBordered;
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
    
    static NSString *nameRegexp = @"^[0-9a-zA-Z_]+$";
    if (isDirectMessage && ![recipient.text matches:nameRegexp withSubstring:nil]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send this message"
                                                        message:@"Recipient's name contains wrong character. Username can only contain letters, numbers and '_'."
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles: nil];
        [alert show];	
        [alert release];    
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

- (void)setTransform:(BOOL)isDelete
{
    if (isDelete) {
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-80.0, 140.0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0.5);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        text.transform = transform;
    }
    else {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0, 0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        text.transform = transform;
    }
}

- (IBAction) clear: (id) sender
{
    [UIView beginAnimations:kDeleteAnimationKey context:self]; 

    UIBarButtonItem *item = (UIBarButtonItem*)[toolbar.items objectAtIndex:0];
    item.enabled = false;

    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self setTransform:true];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];

}

- (IBAction) undo:(id) sender
{
    text.text = undoBuffer;
    [undoBuffer release];
    undoBuffer = nil;
    [self setTransform:true];
    
    UIBarButtonItem *item = (UIBarButtonItem*)[toolbar.items objectAtIndex:0];
    item.enabled = false;
    
    [UIView beginAnimations:kUndoAnimationKey context:self]; 
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self setTransform:false];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (void)replaceButton:(UIBarButtonItem*)item index:(int)index
{
    NSMutableArray *items = [toolbar.items mutableCopy];
    [items replaceObjectAtIndex:index withObject:item];
    [toolbar setItems:items animated:false];
    [items release];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:kDeleteAnimationKey]) {
        [self setTransform:false];

        undoBuffer = [text.text retain];
        text.text = @"";
        charCount.textColor = [UIColor whiteColor];
        sendButton.enabled = false;
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undo:)];
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
    else if ([animationID isEqualToString:kUndoAnimationKey]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
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
        [self setCharCount];
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

- (void)showKeyboard:(NSTimer*)timer
{
    [text becomeFirstResponder];
    text.selectedRange = textRange;
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

- (void)postDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj;
{
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
    
    [progressWindow hide];
    
    if (dic) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate postTweetDidSucceed:dic isDirectMessage:isDirectMessage];
    }       
    
    text.text = @"";
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
    connection = nil;
    [progressWindow hide];
}

- (void)setCharCount
{
    int length = [text.text length];

    if (undoBuffer && length > 0) {
        [undoBuffer release];
        undoBuffer = nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }

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
    
    if (isDirectMessage && [recipient.text length] == 0) {
        sendButton.enabled = false;
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
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    textRange = text.selectedRange;
}

- (void)textViewDidChange:(UITextView *)textView
{
    textRange = text.selectedRange;
    [self setCharCount];
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
    [self.view removeFromSuperview];
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate.window makeKeyWindow];
    
    if (finished && didPost) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate postViewAnimationDidFinish:isDirectMessage];
    }
}
@end
