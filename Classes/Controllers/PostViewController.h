//
//  PostViewController.h
//  TwitterFon
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterClient.h"
#import "Message.h"
#import "ProgressWindow.h"

@interface PostViewController : UIViewController {
    IBOutlet UITextView* text;
    IBOutlet UILabel*    charCount;
    IBOutlet UIBarItem*  sendButton;
    NSObject*            appDelegate;
    TwitterClient*       post;
    BOOL                 didPost;
    BOOL                 isDirectMessage;
    NSRange              textRange;
    
   	IBOutlet ProgressWindow* progressWindow;
}

@property(nonatomic, assign) NSObject* appDelegate;

- (void)startEditWithString:(NSString*)message;
- (void)startEditWithURL:(NSString*)URL;
- (void)startEdit;
- (void)checkProgressWindowState;

- (void) setCharCount;
- (void) saveTweet;

- (IBAction) cancel: (id) sender;
- (IBAction) send: (id) sender;
- (IBAction) clear: (id) sender;

@end
