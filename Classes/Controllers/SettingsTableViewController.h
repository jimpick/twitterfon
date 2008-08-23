//
//  SettingsTableViewController.h
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController {
    IBOutlet UITableViewCell*   username;
    IBOutlet UITableViewCell*   password;

    UITableViewCell*            helps[3];
    
    IBOutlet UIView*            parentView;

    IBOutlet UITextField*       usernameField;
    IBOutlet UITextField*       passwordField;
}

@end
