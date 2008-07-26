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

    message.text = @"Sending...";
    message.font = [UIFont boldSystemFontOfSize:18];
    errorMessage.text = @"";
    errorMessage.font = [UIFont boldSystemFontOfSize:18];
    
    indicator.hidden = false;
    [indicator startAnimating];
    [self makeKeyAndVisible];
}

- (void) fail:(NSString*)error
{
    alert.hidden = false;
    indicator.hidden = true;
    [indicator stopAnimating];
    message.text = @"Failed to send a tweet";
    errorMessage.text = error;
}

- (void) hide
{
    [self resignKeyWindow];
    self.hidden = true;
}

@end
