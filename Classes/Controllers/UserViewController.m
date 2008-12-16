//
//  UserViewController.m
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "UserViewController.h"
#import "UserTimelineController.h"
#import "UserDetailViewController.h"
#import "ColorUtils.h"

NSString* sCellActionText[3] = {
    @"Send a repply Send a DM retweet",
    @"Send a direct message",
    @"Retweet this message",
};

NSString* sUserDetailText[2] = {
    @"This User's Timeline",
    @"Profile",
};

NSString* sYourDetailText[2] = {
    @"Your Timeline",
    @"Your Profile",
};

NSString* sDeleteMessage[2] = {
    @"Delete this tweet",
    @"Delete this message",
};

#define NUM_SECTIONS 3

enum {
    SECTION_MESSAGE,
    SECTION_ACTIONS,
    SECTION_MORE_ACTIONS,
    SECTION_DELETE,
};

int sUserSection[] = {
    SECTION_MESSAGE,
    SECTION_ACTIONS,
    SECTION_MORE_ACTIONS,
};

int sOwnSection[] = {
    SECTION_MESSAGE,
    SECTION_MORE_ACTIONS,
    SECTION_DELETE,
};

enum {
    ROW_MESSAGE,
    ROW_IN_REPLY_TO,
};

enum {
    ROW_USER_TIMELINE,
    ROW_PROFILE,
};

@interface NSObject (UserViewControllerDelegate)
- (void)removeMessage:(Message*)message;
@end

@implementation UserViewController

- (void)initCommon
{
    userView    = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
    actionCell  = [[UserViewActionCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ActionCell"];
    messageCell = [[UserMessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MessageCell"];
    deleteCell  = [[DeleteButtonCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DeleteCell"];
}

- (void)setMessage:(Message*)m
{
    message = [m copy];
    message.cellType = MSG_CELL_TYPE_DETAIL;
    [message updateAttribute];
    
    if (message.inReplyToMessageId) {
        inReplyToMessage = [[Message messageWithId:message.inReplyToMessageId] retain];
        if (inReplyToMessage == nil) {
            inReplyToUser = [[User userWithId:message.inReplyToUserId] retain];
        }
    }        
    actionCell.message = message;
    [userView setUser:message.user];
    self.title = message.user.screenName;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([message.user.screenName caseInsensitiveCompare:username] == NSOrderedSame) {
        isOwnTweet = true;
        sections = sOwnSection;
    }
    else {
        sections = sUserSection;
    }
}

- (id)initWithMessage:(Message*)m
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        [self initCommon];
        [self setMessage:m];
    }
	return self;
}

- (id)initWithMessageId:(sqlite_int64)messageId
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        [self initCommon];
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(messageDidLoad:message:)];
        [twitterClient getMessage:messageId];
    }
	return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    
    if ([self tabBarController].selectedIndex == MSG_TYPE_MESSAGES) {
        isDirectMessage = true;
        isOwnTweet      = true;
    }
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
    message.user.imageContainer = self;
    [inReplyToUser release];
    [inReplyToMessage release];
    [messageCell release];
    [actionCell release];
    [userView release];
    [message release];
    [super dealloc];
}

- (void)messageDidLoad:(TwitterClient*)client message:(id)obj
{
    twitterClient = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;

        Message *m = [Message messageWithJsonDictionary:dic type:MSG_TYPE_FRIENDS];
        [self setMessage:m];
        if (isOwnTweet) {
            [m insertDB];
        }
        else {
            [m insertDBIfFollowing];
        }
        [self.tableView reloadData];
    }
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    twitterClient = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    if (message) {
        return NUM_SECTIONS;
    }
    else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (message) {
        int s = sections[section];
        switch (s) {
            case SECTION_MESSAGE:
                return 1;
            case SECTION_ACTIONS:
                return 1;
            case SECTION_MORE_ACTIONS:
                return 2;
            case SECTION_DELETE:
                return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_MESSAGE && indexPath.row == ROW_MESSAGE) {
        return message.cellHeight;
    }
    else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_MESSAGE && indexPath.row == ROW_MESSAGE) {
        messageCell.message = message;
        [messageCell update];
        messageCell.contentView.backgroundColor = [UIColor clearColor];
        return messageCell;
    }
    
    int section = sections[indexPath.section];
    
    if (section == SECTION_ACTIONS) {
        return actionCell;
    }
    else if (section == SECTION_DELETE) {
        int index = (isDirectMessage) ? 1 : 0;
        [deleteCell setTitle:sDeleteMessage[index]];
        return deleteCell;
    }
    
    static NSString *CellIdentifier = @"UserViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == SECTION_MESSAGE) {
        cell.font = [UIFont boldSystemFontOfSize:14];
        cell.textColor = [UIColor cellLabelColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (inReplyToMessage) {
            cell.text = [NSString stringWithFormat:@"In-reply-to %@: %@", inReplyToMessage.user.screenName, inReplyToMessage.text];
        }
        else if (inReplyToUser) {
            cell.text = [NSString stringWithFormat:@"In-reply-to %@", inReplyToUser.screenName];
        }
        else {
            cell.text = [NSString stringWithFormat:@"In-reply-to-message-id: %lld", message.inReplyToMessageId];
        }
    }
    else if (section == SECTION_MORE_ACTIONS) {
        cell.textAlignment = UITextAlignmentCenter;
        cell.textColor = [UIColor cellLabelColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.text = (isOwnTweet) ? sYourDetailText[indexPath.row] : sUserDetailText[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = sections[indexPath.section];
    switch (section) {
        case SECTION_MESSAGE:
            if (indexPath.row == 1) {
                UserViewController *controller = [UserViewController alloc];
                if (inReplyToMessage) {
                    [[controller initWithMessage:inReplyToMessage] autorelease];
                }
                else {
                    [[controller initWithMessageId:message.inReplyToMessageId] autorelease];
                }
                [self.navigationController pushViewController:controller animated:true];
            }
            break;
        case SECTION_MORE_ACTIONS:
            if (indexPath.row == ROW_USER_TIMELINE) {
                UserTimelineController* userTimeline = [[[UserTimelineController alloc] init] autorelease];
                [userTimeline setUser:message.user];
                [self.navigationController pushViewController:userTimeline animated:true];
            }
            else if (indexPath.row == ROW_PROFILE) {
                UserDetailViewController *detailView = [[[UserDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
                detailView.user = message.user;
                [self.navigationController pushViewController:detailView animated:true];
            }
            break;
            
        case SECTION_DELETE:
        {
            int index = (isDirectMessage) ? 1 : 0;
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:sDeleteMessage[index]
                                                   otherButtonTitles:nil];
            [as showInView:self.navigationController.parentViewController.view];
            [as release];
        }
        break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
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
    
    if ([self tabBarController].selectedIndex == MSG_TYPE_MESSAGES) {
        [postView editDirectMessage:message.user.screenName];
    }
    else {
        [postView inReplyTo:message];
    }
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) {
        return;
    }

    // Delete message
    //
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    TwitterClient* client = [[TwitterClient alloc] initWithTarget:appDelegate action:@selector(messageDidDelete:messages:)];
    client.context = [message retain];

    NSArray *array = self.navigationController.viewControllers;
    for (int i = 0; i < [array count] - 1; ++i) {
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:i];
        if ([c respondsToSelector:@selector(removeMessage:)]) {
            [c removeMessage:message];
        }
    }

    [client destroy:message isDirectMessage:isDirectMessage];

    [self.navigationController popViewControllerAnimated:true];
}

- (void)toggleFavorite:(BOOL)favorited message:(Message*)m
{
    [messageCell toggleFavorite:favorited];
}

@end

