//
//  SettingsTableViewController.m
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TwitterFonAppDelegate.h"

enum {
    SECTION_ACCOUNT,
    SECTION_OPTION,
    SECTION_HELP,
    NUM_SECTIONS,
};

enum {
    ROW_USERNAME,
    ROW_PASSWORD,
    NUM_ROWS_ACCOUNT,
};

enum {
    ROW_SSL,
    NUM_ROWS_OPTION,
};

enum {
    ROW_FOLLOW,
    ROW_HELP,
    NUM_ROWS_HELP,
};

static int sNumRows[NUM_SECTIONS] = {
    NUM_ROWS_ACCOUNT,
    NUM_ROWS_OPTION,
    NUM_ROWS_HELP,
};

static NSString* sSectionHeader[NUM_SECTIONS] = {
    @"Account",
    @"Options",
    @"Need a Help?",
};

@implementation SettingsTableViewController

#define LABEL_TAG       1
#define TEXTFIELD_TAG   2
#define SWITCH_TAG      3

- (void)viewDidLoad
{
	[super viewDidLoad];

    // If the settings are empty, focus to username text area.
	NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (user == nil) {
        [usernameField becomeFirstResponder];
    }
    else {
        usernameField.text = user;
        passwordField.text = pass;
    }
    
    // Set options
    BOOL useSSL = [[NSUserDefaults standardUserDefaults] integerForKey:@"useSSL"];
    if (useSSL) {
        UISwitch *sw = (UISwitch*)[ssl viewWithTag:SWITCH_TAG];
        sw.on = true;
    }
}

- (void) saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style]) {
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUM_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sNumRows[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sSectionHeader[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    switch (indexPath.section) {
        case SECTION_ACCOUNT:
            if (indexPath.row == ROW_USERNAME) {
                cell = username;
            }
            else {
                cell = password;
            }
            UITextField *text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            text.font = [UIFont systemFontOfSize:16];
            break;
            
        case SECTION_OPTION:
            cell = ssl;
            break;
            
        case SECTION_HELP:
            if (indexPath.row == ROW_FOLLOW) {
                cell = follow;
            }
            else if (indexPath.row == ROW_HELP) {
                cell = help;
            }
            break;
            
        default:
            break;
    }
    
    UILabel *label = (UILabel*)[cell viewWithTag:LABEL_TAG];
    label.font = [UIFont boldSystemFontOfSize:16];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    switch (indexPath.section) {
        case SECTION_ACCOUNT:
            if (indexPath.row == 0) {
                cell = username;
            }
            else {
                cell = password;
            }
            UITextField *text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            [text becomeFirstResponder];
            break;
            
        case SECTION_HELP:
            if (indexPath.row == 0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/TwitterFon"]];
            }
            else if (indexPath.row == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://naan.net/trac/wiki/TwitterFon"]];            
            }
            break;
            
        default:
            break;
    }
}

- (void)switchSSL:(id)sender forEvent:(UIEvent *)event
{
    UISwitch *sw = (UISwitch*)sender;
    [[NSUserDefaults standardUserDefaults] setInteger:sw.on forKey:@"useSSL"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    [self saveSettings];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (void)dealloc {
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end


