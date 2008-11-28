//
//  SettingsTableViewController.h
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIBarButtonItem*   doneButton;
    IBOutlet UITableViewCell*   username;
    IBOutlet UITableViewCell*   password;
    IBOutlet UITextField*       usernameField;
    IBOutlet UITextField*       passwordField;
}

- (IBAction) done:(id)sender;

@end
