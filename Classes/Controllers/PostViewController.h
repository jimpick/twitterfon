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
#import "SendingWindow.h"

@interface PostViewController : UIViewController {
    IBOutlet UITextView* text;
    IBOutlet UILabel*    charCount;
    IBOutlet UIBarItem*  sendButton;
    IBOutlet NSObject*   delegate;
    IBOutlet NSObject*   appDelegate;
    TwitterClient*       post;
    BOOL                 didPost;
    BOOL                 isDirectMessage;
    NSRange              textRange;
    
   	IBOutlet SendingWindow* sendingWindow;
}

- (void)startEditWithString:(NSString*)message setDelegate:(id)delegate;
- (void)startEditWithURL:(NSString*)URL setDelegate:(id)delegate;
- (void)startEditWithDelegate:(id)delegate;

- (void) setCharCount;

- (IBAction) cancel: (id) sender;
- (IBAction) send: (id) sender;
- (IBAction) clear: (id) sender;

@end
