//
//  SettingsTableViewController.m
//  TwitterFon
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SettingsViewController.h"
#import "TwitterFonAppDelegate.h"
#import "REString.h"

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

@implementation SettingsViewController

#define LABEL_TAG       1
#define TEXTFIELD_TAG   2

- (void)viewDidLoad
{
	[super viewDidLoad];

    // If the settings are empty, focus to username text area.
	NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    usernameField.text = user;
    passwordField.text = pass;
    
    UIBarButtonItem *done  = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                              style:UIBarButtonItemStyleDone 
                                                             target:self 
                                                             action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = done;
    self.navigationItem.title = @"Setup";
}

- (void) saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:usernameField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setObject:usernameField.text forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUM_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sNumRows[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    return sSectionHeader[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"You can customize TwitterFon preferences\nwith \"Settings\" application.";
    }
    else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    UILabel *label;
    UITextField *text;
    switch (indexPath.section) {
        case SECTION_ACCOUNT:
            if (indexPath.row == ROW_USERNAME) {
                cell = username;
            }
            else {
                cell = password;
            }
            text = (UITextField*)[cell viewWithTag:TEXTFIELD_TAG];
            text.font = [UIFont systemFontOfSize:16];
            
            label = (UILabel*)[cell viewWithTag:LABEL_TAG];
            label.font = [UIFont boldSystemFontOfSize:16];
            break;
            
        case SECTION_HELP:
            cell = [tableView dequeueReusableCellWithIdentifier:@"helpCell"];
            if (!cell) {
                cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"helpCell"] autorelease];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.text =  @"Open Help Page";
            cell.textAlignment = UITextAlignmentCenter;
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
            if (indexPath.row == ROW_HELP) {
                [self openURL:@"http://twitterfon.com/"];
            }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
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

- (IBAction)done:(id)sender
{
    if (![usernameField.text matches:@"^[0-9A-Za-z_]+$" withSubstring:nil]) {
        [[TwitterFonAppDelegate getAppDelegate] alert:@"Invalid screen name" 
                                              message:@"Username can only contain letters, numbers and '_'"];
    }
    else {
        doneButton.enabled = false;    
        [usernameField resignFirstResponder];
        [passwordField resignFirstResponder];
        [self saveSettings];
        TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(accountDidVerify:obj:)];
        [client verify];
    }
}

- (void)accountDidVerify:(TwitterClient*)sender obj:(NSObject*)obj;
{
    if (sender.hasError) {
        [sender alert];
        doneButton.enabled = true;
    }
    else {
        [self dismissModalViewControllerAnimated:true];
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate closeSettingsView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (void)dealloc {
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end


