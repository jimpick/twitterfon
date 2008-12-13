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
#import "MessageCell.h"
#import "UserTimelineController.h"
#import "UserDetailViewController.h"

NSString* sCellActionText[3] = {
    @"Send a repply Send a DM retweet",
    @"Send a direct message",
    @"Retweet this message",
};

NSString* sCellDetailText[2] = {
    @"This User's Timeline",
    @"Profile",
};

NSString* sDeleteMessage[2] = {
    @"Delete this tweet",
    @"Delete this message",
};

@interface NSObject (UserViewControllerDelegate)
- (void)removeMessage:(Message*)message;
@end

@implementation UserViewController

- (id)initWithMessage:(Message*)m
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        message = [m copy];
        message.cellType = MSG_CELL_TYPE_USER;
        [message updateAttribute];
        userView = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
        
        actionCell  = [[UserViewActionCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ActionCell"];
        messageCell = [[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MessageCell"];
        deleteCell  = [[DeleteButtonCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DeleteCell"];
        
        actionCell.message = message;
        
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        ImageStore *imageStore = appDelegate.imageStore;
        NSString *url = [m.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        userView.profileImage = [imageStore getImage:url delegate:self];
        [userView setUser:message.user];
        
        self.title = message.user.screenName;
        
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        if ([message.user.screenName caseInsensitiveCompare:username] == NSOrderedSame) {
            hasDeleteButton = true;
        }
        else  {
            UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
            self.navigationItem.rightBarButtonItem = button;
        }
	}
	return self;
}


- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    
    if ([self tabBarController].selectedIndex == MSG_TYPE_MESSAGES) {
        isDirectMessage = true;
        hasDeleteButton = true;
    }
}

- (void)dealloc {
    [messageCell release];
    [actionCell release];
    [message release];
    [userView release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (hasDeleteButton) ? 4 : 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1;
        case 2:
            return 2;
        case 3:
            return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return message.cellHeight;
    }
    else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        messageCell.message = message;
        [messageCell update:MSG_CELL_TYPE_USER delegate:self];
        messageCell.contentView.backgroundColor = [UIColor clearColor];
        return messageCell;
    }
    else {
        static NSString *CellIdentifier = @"UserViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.textAlignment = UITextAlignmentCenter;
        cell.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
        if (indexPath.section == 1) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            return actionCell;
        }
        else if (indexPath.section == 2) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.text = sCellDetailText[indexPath.row];
        }
        else if (indexPath.section == 3) {
            int index = (isDirectMessage) ? 1 : 0;
            [deleteCell setTitle:sDeleteMessage[index]];
            return deleteCell;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 2:
            if (indexPath.row == 0) {
                UserTimelineController* userTimeline = [[[UserTimelineController alloc] initWithNibName:nil bundle:nil] autorelease];
                [userTimeline setUser:message.user];
                [self.navigationController pushViewController:userTimeline animated:true];
            }
            else if (indexPath.row == 1) {
                UserDetailViewController *detailView = [[[UserDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
                detailView.user = message.user;
                TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
                NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
                detailView.userView.profileImage = [appDelegate.imageStore getImage:url delegate:self];
                
                [self.navigationController pushViewController:detailView animated:true];
            }
            break;
            
        case 3:
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
    if (section == 0) {
        return userView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
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
    
    UIViewController *c = [self.navigationController.viewControllers objectAtIndex:0];
    
    if ([c respondsToSelector:@selector(removeMessage:)]) {
        [c removeMessage:message];
    }

    [client destroy:message isDirectMessage:isDirectMessage];

    [self.navigationController popViewControllerAnimated:true];
}

- (void)toggleFavorite:(BOOL)favorited message:(Message*)m
{
    [messageCell toggleFavorite:favorited];
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
    userView.profileImage = image;
    [userView setNeedsDisplay];
}

@end

