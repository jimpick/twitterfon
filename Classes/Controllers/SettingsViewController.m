//
//  SettingsTableViewController.m
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SettingsViewController.h"
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
    ROW_REPLY,
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

static NSString* sHelpPhrase[NUM_ROWS_HELP] = {
    @"Open @TwitterFon",
    @"Open Help Page",
    @"Send a tweet to @TwitterFon",
};

@implementation SettingsViewController

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

    for (int i = 0; i < 3; ++i) {
        helps[i] = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        helps[i].text = sHelpPhrase[i];
        if (i != ROW_REPLY) {
            helps[i].accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        helps[i].textAlignment = UITextAlignmentCenter;
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
            
            UILabel *label = (UILabel*)[cell viewWithTag:LABEL_TAG];
            label.font = [UIFont boldSystemFontOfSize:16];
            break;
            
        case SECTION_HELP:
            cell = helps[indexPath.row];
            break;
            
        default:
            break;
    }

    
    return cell;
}

- (void)openURL:(NSString*)url
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:url on:[self navigationController]];
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
            if (indexPath.row == ROW_REPLY) {
                TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
                PostViewController* postView = appDelegate.postView;
                
                [[self navigationController].view addSubview:postView.view];
                [postView startEditWithString:@"@TwitterFon "];
                [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];

            }            
            else if (indexPath.row == ROW_FOLLOW) {
                [self openURL:@"http://m.twitter.com/TwitterFon"];
            }
            else if (indexPath.row == ROW_HELP) {
                [self openURL:@"http://naan.net/trac/wiki/TwitterFon"];
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
    for (int i = 0; i < 3; ++i)
        [helps[i] release];
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


