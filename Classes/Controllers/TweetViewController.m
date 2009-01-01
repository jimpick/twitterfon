//
//  TweetViewController.m
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "TweetViewController.h"
#import "UserTimelineController.h"
#import "ProfileViewController.h"
#import "ColorUtils.h"

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
- (void)removeStatus:(Status*)status;
@end

@implementation TweetViewController

- (void)initCommon
{
    userView   = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
    actionCell = [[TweetViewActionCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ActionCell"];
    tweetCell  = [[UserTimelineCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MessageCell"];
    deleteCell = [[DeleteButtonCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DeleteCell"];
}

- (void)setStatus:(Status*)sts
{
    status = [sts copy];
    status.cellType = TWEET_CELL_TYPE_DETAIL;
    [status  updateAttribute];
    
    if (status.inReplyToStatusId) {
        inReplyToStatus = [[Status statusWithId:status.inReplyToStatusId] retain];
#if 0
        if (inReplyToStatus == nil) {
            inReplyToUser = [[User userWithId:status.inReplyToUserId] retain];
        }
#endif
    }        
    actionCell.status = status;
    [userView setUser:status.user];
    self.title = status.user.screenName;

    if ([TwitterFonAppDelegate isMyScreenName:status.user.screenName]) {
        isOwnTweet = true;
        sections = sOwnSection;
    }
    else {
        sections = sUserSection;
    }
}

- (id)initWithMessage:(Status*)sts
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        [self initCommon];
        [self setStatus:sts];
    }
	return self;
}

- (id)initWithMessageId:(sqlite_int64)statusId
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        [self initCommon];
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(messageDidLoad:obj:)];
        [twitterClient getMessage:statusId];
    }
	return self;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    
    if ([self tabBarController].selectedIndex == TWEET_TYPE_MESSAGES) {
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
    [inReplyToUser release];
    [inReplyToStatus release];
    [tweetCell release];
    [actionCell release];
    [userView release];
    [status  release];
    [super dealloc];
}

- (void)messageDidLoad:(TwitterClient*)client obj:(id)obj
{
    twitterClient = nil;
    if (client.hasError) {
        [client alert];
        return;
    }

    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;

        Status* sts = [Status statusWithJsonDictionary:dic type:TWEET_TYPE_FRIENDS];
        [self setStatus:sts];
        if (isOwnTweet) {
            [sts insertDB];
        }
        else {
            [sts insertDBIfFollowing];
        }
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    if (status) {
        return NUM_SECTIONS;
    }
    else {
        return 1;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (status) {
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
        return status.cellHeight;
    }
    else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section == SECTION_MESSAGE && indexPath.row == ROW_MESSAGE) {
        tweetCell.status = status;
        [tweetCell update];
        tweetCell.contentView.backgroundColor = [UIColor clearColor];
        return tweetCell;
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
        if (inReplyToStatus) {
            cell.text = [NSString stringWithFormat:@"In-reply-to %@: %@", inReplyToStatus.user.screenName, inReplyToStatus.text];
        }
        else if (inReplyToUser) {
            cell.text = [NSString stringWithFormat:@"In-reply-to %@", inReplyToUser.screenName];
        }
        else {
            cell.text = [NSString stringWithFormat:@"In-reply-to-message-id: %lld", status.inReplyToStatusId];
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
                TweetViewController *messageView = [TweetViewController alloc];
                if (inReplyToStatus) {
                    [[messageView initWithMessage:inReplyToStatus] autorelease];
                }
                else {
                    [[messageView initWithMessageId:status.inReplyToStatusId] autorelease];
                }
                [self.navigationController pushViewController:messageView animated:true];
            }
            break;
        case SECTION_MORE_ACTIONS:
            if (indexPath.row == ROW_USER_TIMELINE) {
                UserTimelineController* userTimeline = [[[UserTimelineController alloc] init] autorelease];
                [userTimeline setUser:status.user];
                [self.navigationController pushViewController:userTimeline animated:true];
            }
            else if (indexPath.row == ROW_PROFILE) {
                ProfileViewController *profile = [[[ProfileViewController alloc] initWithProfile:status.user] autorelease];
                [self.navigationController pushViewController:profile animated:true];
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
    
    if ([self tabBarController].selectedIndex == TWEET_TYPE_MESSAGES) {
        [postView editDirectMessage:status.user.screenName];
    }
    else {
        [postView inReplyTo:status];
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
    TwitterClient* client = [[TwitterClient alloc] initWithTarget:appDelegate action:@selector(messageDidDelete:obj:)];
    client.context = [status retain];

    NSArray *array = self.navigationController.viewControllers;
    for (int i = 0; i < [array count] - 1; ++i) {
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:i];
        if ([c respondsToSelector:@selector(removeStatus:)]) {
            [c removeStatus:status];
        }
    }

    [client destroy:status isDirectMessage:isDirectMessage];

    [self.navigationController popViewControllerAnimated:true];
}

- (void)toggleFavorite:(BOOL)favorited status:(Status*)m
{
    [tweetCell toggleFavorite:favorited];
}

@end

