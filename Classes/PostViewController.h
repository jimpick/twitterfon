//
//  PostViewController.h
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostTweet.h"

@interface PostViewController : UIViewController {
    IBOutlet UIView*     toolbar;
    IBOutlet UITextView* text;
    IBOutlet UILabel*    charCount;
    IBOutlet UIBarItem*  sendButton;
    UITabBarController*  tab;
    PostTweet*           post;
}

@property (nonatomic, assign) UITextView *text;

- (void) setCharCount;
- (IBAction) cancel: (id) sender;
- (IBAction) send: (id) sender;

@end
