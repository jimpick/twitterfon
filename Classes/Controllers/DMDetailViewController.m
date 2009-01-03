//
//  DMDetailViewController.m
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "DMDetailViewController.h"
#import "ProfileViewController.h"
#import "UserTimelineController.h"
#import "ColorUtils.h"

static NSString* sUserDetailText[2] = {
    @"This User's Timeline",
    @"Profile",
};

static NSString* sYourDetailText[2] = {
    @"Your Timeline",
    @"Your Profile",
};

#define NUM_SECTIONS 3

enum {
    SECTION_MESSAGE,
    SECTION_MORE_ACTIONS,
    SECTION_DELETE,
};

enum {
    ROW_USER_TIMELINE,
    ROW_PROFILE,
};

@interface NSObject (UserViewControllerDelegate)
- (void)removeMessage:(DirectMessage*)message;
@end

@implementation DMDetailViewController

- (id)initWithMessage:(DirectMessage*)value
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    userView    = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
    deleteCell  = [[DeleteButtonCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DeleteCell"];
    messageCell = [[DMDetailCell alloc] initWithMessage:value];
    
    message = value;
    [message loadUserObject];
    [userView setUser:message.sender];
    self.title = message.sender.screenName;
    
    if ([TwitterFonAppDelegate isMyScreenName:message.sender.screenName]) {
        isOwnMessage = true;
    }
    else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
        self.navigationItem.rightBarButtonItem = button;        
    }

	return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (void)dealloc {
    [messageCell release];
    [deleteCell release];
    [userView release];
    [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return NUM_SECTIONS;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case SECTION_MESSAGE:
            return 1;
        case SECTION_MORE_ACTIONS:
            return 2;
        case SECTION_DELETE:
            return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_MESSAGE) {
        return messageCell.cellHeight;
    }
    else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_MESSAGE) {
        return messageCell;
    }
    if (indexPath.section == SECTION_DELETE) {
        [deleteCell setTitle:@"Delete this message"];
        return deleteCell;
    }
    
    static NSString *CellIdentifier = @"UserViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == SECTION_MORE_ACTIONS) {
        cell.textAlignment = UITextAlignmentCenter;
        cell.textColor = [UIColor cellLabelColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.text = (isOwnMessage) ? sYourDetailText[indexPath.row] : sUserDetailText[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    switch (indexPath.section) {
        case SECTION_MESSAGE:
            break;
        case SECTION_MORE_ACTIONS:
            if (indexPath.row == ROW_USER_TIMELINE) {
                UserTimelineController* userTimeline = [[[UserTimelineController alloc] init] autorelease];
                [userTimeline setUser:message.sender];
                [self.navigationController pushViewController:userTimeline animated:true];
            }
            else if (indexPath.row == ROW_PROFILE) {
                ProfileViewController *profile = [[[ProfileViewController alloc] initWithProfile:message.sender] autorelease];
                [self.navigationController pushViewController:profile animated:true];
            }
            break;
            
        case SECTION_DELETE:
        {
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Delete this message"
                                                   otherButtonTitles:nil];
            [as showInView:self.navigationController.parentViewController.view];
            [as release];
        }
        break;
            
        default:
            break;
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_MESSAGE) {
        return userView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_MESSAGE) {
        return userView.height;
    }
    else {
        return 0;
    }
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    [postView editDirectMessage:message.sender.screenName];
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }

    // Delete message
    //
    TwitterClient* client = [[TwitterClient alloc] initWithTarget:[TwitterFonAppDelegate getAppDelegate]
                                                           action:@selector(messageDidDelete:obj:)];
    client.context = [message retain];
    [client destroy:message];

    [self.navigationController popViewControllerAnimated:true];
}

@end

