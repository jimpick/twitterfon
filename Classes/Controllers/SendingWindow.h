//
//  SendingWindow.h
//  TwitterFon
//
//  Created by kaz on 7/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressWindow : UIWindow {
    IBOutlet UILabel*                   message;
    IBOutlet UIActivityIndicatorView*   indicator;
}

- (void) show;
- (void) hide;

@end
