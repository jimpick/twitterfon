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
    SECTION_HELP,
    NUM_SECTIONS,
};

enum {
    ROW_USERNAME,
    ROW_PASSWORD,
    NUM_ROWS_ACCOUNT,
};

enum {
    ROW_FOLLOW,
    ROW_HELP,
    NUM_ROWS_HELP,
};

static int sNumRows[NUM_SECTIONS] = {
    NUM_ROWS_ACCOUNT,
    NUM_ROWS_HELP,
};

static NSString* sSectionHeader[NUM_SECTIONS] = {
    @"Account",
    @"Need a Help?",
};

@implementation SettingsTableViewController

#define LABEL_TAG       1
#define TEXTFIELD_TAG   2

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
    follow = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    help   = [[UITableViewCell alloc] initWithFrame:CGRectZero];
    follow.textAlignment = UITextAlignmentCenter;
    help.textAlignment = UITextAlignmentCenter;
    follow.text = @"Follow @TwitterFon on Twitter";
    help.text   = @"Open Help Page with Safari";
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
            
            UILabel *label = (UILabel*)[cell viewWithTag:LABEL_TAG];
            label.font = [UIFont boldSystemFontOfSize:16];
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

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            [text becomeFirstResponder];
            break;
            
        case SECTION_HELP:
            if (indexPath.row == ROW_FOLLOW) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/TwitterFon"]];
            }
            else if (indexPath.row == ROW_HELP) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://naan.net/trac/wiki/TwitterFon"]];            
            }
            break;
            
        default:
            break;
    }
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


