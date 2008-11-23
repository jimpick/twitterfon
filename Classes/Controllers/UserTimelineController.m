//
//  UserTimelineController.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UserTimelineController.h"
#import "TwitterFonAppDelegate.h"
#import "UserDetailViewController.h"
#import "LinkViewController.h"
#import "MessageCell.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)removeMessage:(Message*)message;
@end

@implementation UserTimelineController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        timeline = [[Timeline alloc] initWithDelegate:self];
        deletedMessage = [[NSMutableArray alloc] init];
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        imageStore = appDelegate.imageStore;
        userCell = [[UserCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserCell"];
        loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
	}
	return self;
}

- (void)dealloc {
    [userCell release];
    [loadCell release];
    [twitterClient release];
    [deletedMessage release];
    [message release];
    [timeline release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [loadCell.spinner stopAnimating];
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    self.title = screenName;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([screenName caseInsensitiveCompare:username] == NSOrderedSame) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)setMessage:(Message *)aMessage
{
    message = [aMessage copy];
    message.type = MSG_TYPE_USER;
    [message updateAttribute];
    screenName = message.user.screenName;
    
    [loadCell setType:MSG_TYPE_LOAD_USER_TIMELINE];
    
    [timeline appendMessage:message];
    [self.tableView reloadData];
    [self setNavigationBar];
}

- (void)loadUserTimeline:(NSString*)aScreenName
{
    message = nil;
    indexOfLoadCell = 1;
    screenName = [aScreenName substringFromIndex:1];
    
    [loadCell setType:MSG_TYPE_LOADING];
    [loadCell.spinner startAnimating];
    
    [self setNavigationBar];
    
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:messages:)];
    [twitterClient getUserTimeline:screenName params:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [timeline countMessages] + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 113;
    }
    else {
        Message *m = [timeline messageAtIndex:indexPath.row - 1];
        if (m) {
            return m.cellHeight;
        }
        else {
            return 48;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0) {
        if (message) {
            NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
            userCell.userView.profileImage = [imageStore getImage:url delegate:self];
            [userCell.userView setUser:message.user delegate:self];
        }
        return userCell;
    }
    else {
        Message *m = [timeline messageAtIndex:indexPath.row - 1];        
        if (m) {
            MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
            if (!cell) {
                cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
            }
            cell.message = m;
            cell.inEditing = self.editing;
            
            if (m.favorited) {
                [cell.profileImage setImage:[MessageCell favoritedImage] forState:UIControlStateNormal];
            }
            else {
                [cell.profileImage setImage:[MessageCell favoriteImage] forState:UIControlStateNormal];
            }
            [cell update:MSG_TYPE_USER delegate:self];
            TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
            if ([timeline countMessages] == 1 && appDelegate.selectedTab == TAB_MESSAGES) {
                cell.profileImage.hidden = true;
            }
            return cell;
        }
        else {
            return loadCell;
        }
    }

    // won't come here.
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0) {
        if ([timeline countMessages] == 0) {
            return;
        }
        UserDetailViewController *detailView = [[[UserDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        detailView.user = message.user;
        NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        detailView.userView.profileImage = [imageStore getImage:url delegate:self];
        
        [self.navigationController pushViewController:detailView animated:true];
        return;
    }
    
    Message* m = [timeline messageAtIndex:indexPath.row - 1];
    if (m) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (twitterClient) return;
    
    [loadCell.spinner startAnimating];
    
    if (loadCell.type == MSG_TYPE_REQUEST_FOLLOW) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(followDidRequest:messages:)];
        [twitterClient friendship:screenName create:true];

    }
    else {
        indexOfLoadCell = indexPath.row;
        int page = ([timeline countMessages] / 20) + 1;
        
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:messages:)];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        if (page >= 2) {
            [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        }
        
        [twitterClient getUserTimeline:screenName params:param];
    }
    
}

- (void)userTimelineDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{

    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0] animated:true];
    [loadCell setType:MSG_TYPE_LOAD_FROM_WEB];
    
    if (obj == nil) {
        goto out;
    }
    
    NSArray *ary = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        ary = (NSArray*)obj;
    }
    else {
        goto out;
    }
    
    if ([ary count] == 0) goto out;
    
    NSMutableArray *insertIndexPath = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *deleteIndexPath = [[[NSMutableArray alloc] init] autorelease];

    // Remove first message
    BOOL needReplace = false;
    Message* firstMessage = [[[timeline messageAtIndex:0] retain] autorelease];
    if ([timeline countMessages] == 1) {
        [timeline removeMessageAtIndex:0];
        needReplace = true;
    }
    
    // Add messages to the timeline
    for (int i = 0; i < [ary count]; ++i) {
        Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:MSG_TYPE_USER];
        [timeline appendMessage:m];
    }

    if (message) {
        [message release];
    }
    message = [[timeline lastMessage] copy];
    message.type = MSG_TYPE_USER;
    [message updateAttribute];

    NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
    userCell.userView.profileImage = [imageStore getImage:url delegate:self];
    [userCell.userView setUser:message.user delegate:self];
    
    if (needReplace) {
        if (firstMessage.messageId != [timeline messageAtIndex:0].messageId) {
            [deleteIndexPath addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
            --indexOfLoadCell;
        }
    }
    
    int count = [ary count];
    if (count > 8) count = 8;
    for (int i = 0; i < count; ++i) {
        [insertIndexPath addObject:[NSIndexPath indexPathForRow:indexOfLoadCell + i inSection:0]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPath withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
  out:
	[twitterClient autorelease];
    twitterClient = nil;
}

- (void)followDidRequest:(TwitterClient*)sender messages:(NSObject*)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [loadCell setType:MSG_TYPE_REQUEST_FOLLOW_SENT];
        loadCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [sender autorelease];
    twitterClient = nil;
}

// UserCell delegate
//
- (void)didTouchURL:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:message.user.url on:[self navigationController]];
}

- (void)didTouchProfileImage:(MessageCell*)cell
{

    [cell toggleSpinner:true];
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;    
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:appDelegate action:@selector(favoriteDidChange:messages:)];
    client.context = [cell.message retain];
    [client favorite:cell.message];
}

- (void)toggleFavorite:(BOOL)favorited message:(Message*)m
{
    int index = [timeline indexOfObject:m];
    if (index < 0) return;
    MessageCell* cell = (MessageCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0]];
    
    if (favorited) {
        [cell.profileImage setImage:[MessageCell favoritedImage] forState:UIControlStateNormal];
    }
    else {
        [cell.profileImage setImage:[MessageCell favoriteImage] forState:UIControlStateNormal];
    }    

    [cell toggleSpinner:false];

    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [cell.profileImage.layer addAnimation:animation forKey:@"favoriteButton"];
}

- (void)userDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    NSDictionary *dic = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;

        User *user = [[[User alloc] initWithJsonDictionary:dic] autorelease];
        NSString *url = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        userCell.userView.profileImage = [imageStore getImage:url delegate:self];    
        [userCell.userView setNeedsDisplay];
        
        [self.tableView reloadData];
    }
    [sender release];
    twitterClient = nil;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0] animated:true];
    [loadCell setType:MSG_TYPE_LOAD_USER_TIMELINE];

    [sender autorelease];
    twitterClient = nil;
    
    if (sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP) {
        [loadCell setType:MSG_TYPE_REQUEST_FOLLOW];
    }
    
    if (sender.statusCode == 401) {
        
        [loadCell setType:MSG_TYPE_REQUEST_FOLLOW];

        userCell.accessoryType = UITableViewCellAccessoryNone;
        userCell.userView.protected = true;
        [userCell.userView setNeedsDisplay];
        
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userDidReceive:messages:)];
        [twitterClient getUser:screenName];
    }
    else {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:error
                                           message:detail
                                          delegate:self
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles: nil];
        
        [alert show];	
        [alert release];
    }
}

- (void)didTouchLinkButton:(Message*)aMessage links:(NSArray*)array
{
    if ([array count] == 1) {
        NSString* url = [array objectAtIndex:0];
        NSRange r = [url rangeOfString:@"http://"];
        if (r.location != NSNotFound) {
            TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate openWebView:url on:self.navigationController];
        }
        else {
            UserTimelineController *userTimeline = [[UserTimelineController alloc] initWithNibName:nil bundle:nil];
            [userTimeline autorelease];
            [userTimeline loadUserTimeline:[array objectAtIndex:0]];
            
            [self.navigationController pushViewController:userTimeline animated:true];
        }
    }
    else {
        LinkViewController* linkView = [[[LinkViewController alloc] init] autorelease];
        linkView.message = message;
        linkView.links   = array;
        [self.navigationController pushViewController:linkView animated:true];
    }
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    NSString *msg;
    if ([self tabBarController].selectedIndex == MSG_TYPE_MESSAGES) {
        msg = [NSString stringWithFormat:@"d %@ ", screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", screenName];
    }
    
    [postView startEditWithString:msg];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return false;
    
    if (twitterClient) return false;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([screenName caseInsensitiveCompare:username] == NSOrderedSame) {
        Message* m = [timeline messageAtIndex:indexPath.row - 1];
        return (m) ? true : false;
    }
    else {
        return false;
    }
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Message *m = [timeline messageAtIndex:indexPath.row - 1];
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        TwitterClient* client = [[TwitterClient alloc] initWithTarget:appDelegate action:@selector(messageDidDelete:messages:)];
        client.context = [m retain];
        [timeline removeMessage:m];
        
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:0];
        
        if ([c respondsToSelector:@selector(removeMessage:)]) {
            [c removeMessage:m];
        }
        
        [client destroy:m];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [super setEditing:editing animated:animated];
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
    userCell.userView.profileImage = image;
    [userCell.userView setNeedsDisplay];
}

@end

