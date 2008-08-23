//
//  SettingsTableViewController.h
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController {
    IBOutlet UITableViewCell* username;
    IBOutlet UITableViewCell* password;

    IBOutlet UITableViewCell* ssl;

    IBOutlet UITableViewCell* follow;
    IBOutlet UITableViewCell* help;
    IBOutlet UIBarButtonItem* button;
    IBOutlet UITextField*     usernameField;
    IBOutlet UITextField*     passwordField;
}

- (void)switchSSL:(id)sender forEvent:(UIEvent *)event;

@end
