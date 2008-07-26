//
//  SendingWindow.h
//  TwitterFon
//
//  Created by kaz on 7/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SendingWindow : UIWindow {
    IBOutlet UILabel*                   message;
    IBOutlet UILabel*                   errorMessage;
    IBOutlet UIActivityIndicatorView*   indicator;
    IBOutlet UIImageView*               alert;
}

- (void) show;
- (void) fail:(NSString*)error;
- (void) hide;

@end
