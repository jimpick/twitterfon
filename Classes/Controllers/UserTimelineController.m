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
#import "LinkViewController.h"
#import "MessageCell.h"

@interface NSObject (ViewControllerDelegate)
- (void)updateFavorite:(Message*)message;
- (void)removeMessage:(Message*)message;
@end

@implementation UserTimelineController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
        timeline = [[Timeline alloc] initWithDelegate:self];
        deletedMessage = [[NSMutableArray alloc] init];
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        imageStore = appDelegate.imageStore;
	}
	return self;
}

- (void)dealloc {
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
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)setNavigationBar:(NSString*)screenName
{
    self.title = screenName;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([screenName compare:username] == NSOrderedSame) {
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
    
    [timeline appendMessage:message];
    [self.tableView reloadData];
    [self setNavigationBar:message.user.screenName];
}

- (void)loadUserTimeline:(NSString*)screenName
{
    message = nil;
    indexOfLoadCell = 1;
    
    [self setNavigationBar:[screenName substringFromIndex:1]];
    
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:messages:)];
    [twitterClient getUserTimeline:[screenName substringFromIndex:1] params:nil];
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
            userCell.image = [imageStore getImage:url delegate:self];
            [userCell update:message delegate:self];
        }
        else {
            [userCell clear];
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
            return cell;
        }
        else {
            LoadCell * cell =  (LoadCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadCell"];
            if (!cell) {
                cell = [[[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"] autorelease];
            }
            if (message) {
                [cell setType:([timeline countMessages] > 1) ? MSG_TYPE_LOAD_FROM_WEB : MSG_TYPE_LOAD_USERTIMELINE];
            }
            else {
                [cell setType:MSG_TYPE_LOADING];
                [cell.spinner startAnimating];
            }
            return cell;
        }
    }

    // won't come here.
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0) return;
    
    Message* m = [timeline messageAtIndex:indexPath.row - 1];
    if (m) return;
    
    if (twitterClient) return;
    
    LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.spinner startAnimating];

    indexOfLoadCell = indexPath.row;
    int page = ([timeline countMessages] / 20) + 1;
    
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:messages:)];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page >= 2) {
        [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    [twitterClient getUserTimeline:message.user.screenName params:param];
}

- (void)userTimelineDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
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
    [userCell update:message delegate:self];
    NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
    userCell.image = [imageStore getImage:url delegate:self];
    [userCell update:message delegate:self];
    
    if (needReplace) {
        if (firstMessage.messageId != [timeline messageAtIndex:0].messageId) {
            [deleteIndexPath addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        }
    }
    [deleteIndexPath addObject:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0]];
    
    int count = [ary count];
    if (count > 8) count = 8;
    for (int i = (needReplace) ? 0 : 1; i < count; ++i) {
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

// UserCell delegate
//
- (void)didTouchURL:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:message.user.url on:[self navigationController]];
}

- (void)didTouchProfileImage:(MessageCell*)cell
{
    if (twitterClient) return;
    
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(favoriteDidChange:messages:)];
    twitterClient.context = cell;
    [twitterClient favorite:cell.message];
}

- (void)toggleFavorite:(BOOL)favorited cell:(MessageCell*)cell
{
    cell.message.favorited = favorited;
    [cell.message updateFavoriteState];
    
    if (favorited) {
        [cell.profileImage setImage:[MessageCell favoritedImage] forState:UIControlStateNormal];
    }
    else {
        [cell.profileImage setImage:[MessageCell favoriteImage] forState:UIControlStateNormal];
    }    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [cell.profileImage.layer addAnimation:animation forKey:@"favoriteButton"];

    UIViewController *top = [self.navigationController.viewControllers objectAtIndex:0];
    if ([top respondsToSelector:@selector(updateFavorite:)]) {
        [top updateFavorite:cell.message];
    }
}

- (void)favoriteDidChange:(TwitterClient*)sender messages:(NSObject*)obj
{

    if ([obj isKindOfClass:[NSDictionary class]]) {
        MessageCell *cell = sender.context;
        
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 messageId = [[dic objectForKey:@"id"] longLongValue];
        if (cell.message.messageId != messageId) {
            NSLog(@"Someting wrong with contet. Ignore error...");
            return;
        }
        BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
        
        [self toggleFavorite:favorited cell:cell];
     
    }
    [twitterClient autorelease];
    twitterClient = nil;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    if (sender.request == TWITTER_REQUEST_FAVORITE ||
        sender.request == TWITTER_REQUEST_DESTROY_FAVORITE) {
        if (sender.statusCode == 404) {
            BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
            MessageCell *cell = sender.context;
            [self toggleFavorite:favorited cell:cell];
        }
    }
    else {
        if (sender.request == TWITTER_REQUEST_TIMELINE) {
            LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0]];
            if ([cell isKindOfClass:[LoadCell class]]) {
                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0] animated:true];
                [cell.spinner stopAnimating];
            }
        }

        UIAlertView *alert;
        if (sender.statusCode == 401) {
            alert = [[UIAlertView alloc] initWithTitle:@"This user has protected their updates."
                                               message:@"You need to send a request before you can start following this person."
                                              delegate:self
                                     cancelButtonTitle:@"Close"
                                     otherButtonTitles: nil];

        }
        else {
            alert = [[UIAlertView alloc] initWithTitle:error
                                               message:detail
                                                delegate:self
                                     cancelButtonTitle:@"Close"
                                     otherButtonTitles: nil];
        }
    

        [alert show];	
        [alert release];
    }
    
    [sender autorelease];
    twitterClient = nil;
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
            UserTimelineController *userTimeline = [[UserTimelineController alloc] initWithNibName:@"UserView" bundle:nil];
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
        msg = [NSString stringWithFormat:@"d %@ ", message.user.screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", message.user.screenName];
    }
    
    [postView startEditWithString:msg];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return false;
    
    Message* m = [timeline messageAtIndex:indexPath.row - 1];
    return (m) ? true : false;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Message *m = [timeline messageAtIndex:indexPath.row - 1];
        TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(messageDidDelete:messages:)];
        client.context = [m retain];
        [timeline removeMessage:m];
        
        [client destroy:m];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)messageDidDelete:(TwitterClient*)client messages:(NSObject*)obj
{
    [client autorelease];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 messageId = [[dic objectForKey:@"id"] longLongValue];        
        Message *m = (Message*)client.context;
        if (m.messageId == messageId) {
            [m deleteFromDB];
            UIViewController *top = [self.navigationController.viewControllers objectAtIndex:0];
            if ([top respondsToSelector:@selector(removeMessage:)]) {
                [top removeMessage:m];
            }
            [m release];
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [super setEditing:editing animated:animated];
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
    userCell.image = image;
	[self.tableView reloadData];
}

@end

