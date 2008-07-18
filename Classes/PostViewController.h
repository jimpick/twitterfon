//
//  PostViewController.h
//  TwitterPhox
//
//  Created by kaz on 7/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostViewController : UIViewController {
    IBOutlet UITextView* text;
    IBOutlet UILabel*    charCount;
    IBOutlet UIToolbar*  toolbar;
}

- (IBAction) cancel: (id) sender;
- (IBAction) send: (id) sender;

@end
