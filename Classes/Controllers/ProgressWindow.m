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

    [indicator startAnimating];
    self.hidden = false;
    [self makeKeyAndVisible];
}

- (void) hide
{
    self.hidden = true;
    [self resignKeyWindow];
    [indicator stopAnimating];
}

@end
