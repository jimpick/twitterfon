//
//  PostViewController.h
//  TwitterFon
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterClient.h"
#import "TwitPicClient.h"
#import "ProgressWindow.h"
#import "FolloweesViewController.h"
#import "LocationManager.h"
#import "Status.h"
#import "PostView.h"

@interface PostViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UITextView*                text;
    IBOutlet UIToolbar*                 toolbar;
    IBOutlet PostView*                  postView;
    IBOutlet UITextField*               recipient;
    
   	IBOutlet ProgressWindow*            progressWindow;

    IBOutlet UIBarButtonItem*           sendButton;
    IBOutlet UIBarButtonItem*           locationButton;
    IBOutlet UIBarButtonItem*           photoButton;
    IBOutlet UIActivityIndicatorView*   indicator;
    IBOutlet UILabel*                   accuracy;


    UIImage*                    selectedPhoto;
    float                       latitude, longitude;
    
    TFConnection*               connection;
    BOOL                        didPost;
    BOOL                        isDirectMessage;
    BOOL                        recipientIsFirstResponder;
    NSRange                     textRange;

    UINavigationController*     navigation;
    FolloweesViewController*    FolloweesViewController;
}

@property(nonatomic, assign) UINavigationController* navigation;
@property(nonatomic, retain) UIImage*  selectedPhoto;

- (void)post;
- (void)retweet:(NSString*)status;
- (void)reply:(NSString*)user;
- (void)inReplyTo:(Status*)status;
- (void)editWithURL:(NSString*)URL;
- (void)editWithURL:(NSString*)URL title:(NSString*)title;
- (void)editDirectMessage:(NSString*)aRecipient;

- (void)checkProgressWindowState;
- (void)friendsViewDidSelectFriend:(NSString*)screenName;
- (void)friendsViewDidDisappear;
- (void)imagePickerControllerDidDisappear;

- (void) saveTweet;

- (IBAction) close:   (id) sender;
- (IBAction) send:    (id) sender;
- (IBAction) cancel:  (id) sender;
- (IBAction) friends: (id) sender;
- (IBAction) photos:  (id) sender;
- (IBAction) location:(id) sender;
@end
