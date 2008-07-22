//
//  SendingWindow.h
//  TwitterFon
//
//  Created by kaz on 7/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SendingWindow : UIWindow {
    IBOutlet UILabel*                   label;
    IBOutlet UIActivityIndicatorView*   indicator;
}

@property(nonatomic, retain) IBOutlet UILabel* label;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

@end
