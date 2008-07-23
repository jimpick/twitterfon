//
//  SendingWindow.m
//  TwitterFon
//
//  Created by kaz on 7/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SendingWindow.h"


@implementation SendingWindow

- (void) show
{
    self.windowLevel = UIWindowLevelAlert;
    alert.hidden = true;
    label.text = @"Sending...";
    label.font = [UIFont boldSystemFontOfSize:18];
    indicator.hidden = false;
    [indicator startAnimating];
    [self makeKeyAndVisible];
}

- (void) fail
{
    alert.hidden = false;
    indicator.hidden = true;
    [indicator stopAnimating];
    label.text = @"Failed to send a tweet";
}

- (void) hide
{
    [self resignKeyWindow];
    self.hidden = true;
}

@end
