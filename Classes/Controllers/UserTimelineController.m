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
#import "MessageCell.h"

@interface UIViewController (UserTimelineControllerDelegate)
- (void)removeMessage:(Message*)message;
- (void)updateFavorite:(Message*)message;
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
    [deletedMessage release];
    [message release];
    [timeline release];
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated {
    if (timeline) {
        [timeline cancel];
    }
}

- (void)setMessage:(Message *)aMessage
{
    // Reset timeline if needed
    //
    if (message && message.user.userId != aMessage.user.userId) {
        NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        [imageStore releaseImage:url];
        [timeline release];
        timeline = [[Timeline alloc] initWithDelegate:self];
    }

    if (message == nil || message.messageId != aMessage.messageId) {
        [message release];
        message = [aMessage copy];
        if ([timeline countMessages] == 1) {
            [timeline release];
            timeline = [[Timeline alloc] initWithDelegate:self];
        }
    }
    message.type = MSG_TYPE_USER;
    [message updateAttribute];
    
    if ([timeline countMessages] == 0) {
        [timeline appendMessage:message];
    }

    [self.tableView reloadData];
    self.title = message.user.screenName;

    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([message.user.screenName compare:username] == NSOrderedSame) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
        self.navigationItem.rightBarButtonItem = button;
    }
    
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
        NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        userCell.image = [imageStore getImage:url delegate:self];
        [userCell update:message delegate:self];
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
            [cell setType:([timeline countMessages] > 1) ? MSG_TYPE_LOAD_FROM_WEB : MSG_TYPE_LOAD_USERTIMELINE];
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
    
    LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.spinner startAnimating];

    indexOfLoadCell = indexPath.row;
    int page = ([timeline countMessages] / 20) + 1;
    [timeline getUserTimeline:message.user.userId page:page insertAt:indexPath.row - 1];
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
    TwitterClient *twitterClient = [[TwitterClient alloc] initWithDelegate:self];
    twitterClient.context = cell;
    [twitterClient favorite:cell.message];
}

- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj
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
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [cell.profileImage.layer addAnimation:animation forKey:@"favoriteButton"];
        
        [[self.navigationController.viewControllers objectAtIndex:0] updateFavorite:cell.message];
      
    }
    [sender autorelease];
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    if (sender.statusCode == 404) {
        BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
        MessageCell *cell = sender.context;
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
        
        [[self.navigationController.viewControllers objectAtIndex:0] updateFavorite:cell.message];
    }
    
    [sender autorelease];
}

- (void)didTouchLinkButton:(NSString*)url
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:url on:[self navigationController]];
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;

    NSString *msg;
    if ([self tabBarController].selectedIndex == MSG_TYPE_MESSAGES) {
        msg = [NSString stringWithFormat:@"d %@ ", message.user.screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", message.user.screenName];
    }
    
    [[self navigationController].view addSubview:postView.view];
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
        [deletedMessage addObject:[[timeline messageAtIndex:indexPath.row - 1] retain]];
        [timeline deleteMessageAtIndex:indexPath.row - 1];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)messageDidDelete:(sqlite_int64)messageId;
{
    for (int i = 0; i < [deletedMessage count]; ++i) {
        Message *m = [deletedMessage objectAtIndex:i];
        if (m.messageId = messageId) {
            [m deleteFromDB];
            [[self.navigationController.viewControllers objectAtIndex:0] removeMessage:m];
            [deletedMessage removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [super setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
    userCell.image = image;
	[self.tableView reloadData];
}

//
// TimelineDelegate
//
- (void)timelineDidReceiveNewMessage:(Message*)msg
{
}

- (void)timelineDidUpdate:(int)count insertAt:(int)position
{
    if (!self.view.hidden && timeline && [timeline countMessages]) {
        NSMutableArray *insertIndexPath = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *deleteIndexPath = [[[NSMutableArray alloc] init] autorelease];
        
        // Replace message if the current message is not latest one.
        //
        BOOL needReplaceMessage = ([timeline messageAtIndex:0].messageId != message.messageId) ? true : false;
        if (position == 0 && needReplaceMessage) {
            [deleteIndexPath addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
        }
        
        [deleteIndexPath addObject:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0]];
        
        //
        // Avoid to create too many table cell.
        //
        if (count > 8) count = 8;
        if (position == 0) {
            for (int i = (needReplaceMessage) ? 1 : 2; i <= count; ++i) {
                [insertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }        
        }
        else {
            for (int i = 0; i < count; ++i) {
                [insertIndexPath addObject:[NSIndexPath indexPathForRow:position + i + 1 inSection:0]];
            }        
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPath withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
}

- (void)timelineDidFailToUpdate
{
    LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexOfLoadCell inSection:0]];
    if ([cell isKindOfClass:[LoadCell class]]) {
        [cell.spinner stopAnimating];
    }
}

@end

