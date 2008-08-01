//
//  SendingWindow.m
//  TwitterFon
//
//  Created by kaz on 7/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ProgressWindow.h"


@implementation ProgressWindow

- (void) show
{
    self.windowLevel = UIWindowLevelAlert;

    message.text = @"Sending...";
    message.font = [UIFont boldSystemFontOfSize:18];
    indicator.hidden = false;
    [indicator startAnimating];
    [self makeKeyAndVisible];
}

- (void) hide
{
    [self resignKeyWindow];
    [indicator stopAnimating];
    self.hidden = true;
}

@end
