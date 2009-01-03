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
#import "ProfileViewController.h"
#import "TweetViewController.h"
#import "UserTimelineCell.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)removeStatus:(Status*)status;
@end

@implementation UserTimelineController

@synthesize screenName;

- (id)init
{
    if (self = [super initWithNibName:nil bundle:nil]) {
		// Initialization code
        self.tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        timeline = [[Timeline alloc] init];

        userCell = [[UserCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UserCell"];
        loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
        user = nil;
        page = 1;
	}
	return self;
}

- (void)dealloc {
    [screenName release];
    [userCell release];
    [loadCell release];
    [twitterClient release];
    [timeline release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    [self.tableView reloadData];
    [self.tableView setContentOffset:contentOffset animated:false];
}

- (void)viewDidDisappear:(BOOL)animated {
    [loadCell.spinner stopAnimating];
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
    contentOffset = self.tableView.contentOffset;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    self.title = screenName;
    
    if ([TwitterFonAppDelegate isMyScreenName:screenName]) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)setUser:(User *)aUser
{
    user = aUser;
    [userCell.userView setUser:user];
    self.screenName = user.screenName;
    
    [self loadUserTimeline:user.screenName];
}

- (void)loadUserTimeline:(NSString*)aScreenName
{
    indexOfLoadCell = 1;
    self.screenName = aScreenName;
    
    [loadCell setType:MSG_TYPE_LOADING];
    [loadCell.spinner startAnimating];
    
    [self setNavigationBar];
    
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:obj:)];
    [twitterClient getUserTimeline:screenName params:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [timeline countStatuses] + 1;
    if (page > 0) ++count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 113;
    }
    else {
        Status* sts = [timeline statusAtIndex:indexPath.row - 1];
        if (sts) {
            return sts.cellHeight;
        }
        else {
            return ([timeline countStatuses]) ? 78 : 48;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0) {
        if (user) {
            [userCell.userView setUser:user];
        }
        return userCell;
    }
    else {
        Status* status = [timeline statusAtIndex:indexPath.row - 1];
        if (status) {
            UserTimelineCell* cell = (UserTimelineCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
            if (!cell) {
                cell = [[[UserTimelineCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
            }
        
            cell.status = status;
            cell.inEditing = self.editing;
            [cell update];
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
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.row == 0) {
        if ([timeline countStatuses] == 0) {
            return;
        }
        ProfileViewController *profile = [[[ProfileViewController alloc] initWithProfile:user] autorelease];
        [self.navigationController pushViewController:profile animated:true];
        return;
    }
    
    Status* sts = [timeline statusAtIndex:indexPath.row - 1];
    if (sts) {
        // Display user timeline
        //
        TweetViewController* tweetView = [[[TweetViewController alloc] initWithMessage:sts] autorelease];
        [self.navigationController pushViewController:tweetView animated:TRUE];
        return;
    }
    
    if (twitterClient) return;
    [loadCell.spinner startAnimating];
    
    if (loadCell.type == MSG_TYPE_REQUEST_FOLLOW) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(followDidRequest:obj:)];
        [twitterClient friendship:screenName create:true];

    }
    else if (page > 0) {
        indexOfLoadCell = indexPath.row;
        ++page;
        
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userTimelineDidReceive:obj:)];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        if (page >= 2) {
            [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        }
        
        [twitterClient getUserTimeline:screenName params:param];
    }
    
}

- (void)userTimelineDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;
    [loadCell setType:MSG_TYPE_LOAD_FROM_WEB];
    
    if (sender.hasError) {
        if (sender.statusCode == 401) {
            [loadCell setType:MSG_TYPE_REQUEST_FOLLOW];
            
            userCell.accessoryType = UITableViewCellAccessoryNone;
            userCell.userView.protected = true;
            [userCell.userView setNeedsDisplay];
            
            twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userDidReceive:obj:)];
            [twitterClient getUser:screenName];
        }
        else {
            [sender alert];
        }                
        return;
    }
    
    if (obj == nil) {
        return;
    }
    
    NSArray *ary = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        ary = (NSArray*)obj;
    }
    else {
        return;
    }
    
    if ([ary count] == 0) {
        page = -1;
        [self.tableView beginUpdates];
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexOfLoadCell inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        return;
    }
    
    NSMutableArray *insertIndexPath = [[[NSMutableArray alloc] init] autorelease];

    // Add messages to the timeline
    for (int i = 0; i < [ary count]; ++i) {
        Status* sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i] type:TWEET_TYPE_FRIENDS];
        sts.cellType = TWEET_CELL_TYPE_USER;
        [sts updateAttribute];
        [timeline appendStatus:sts];
    }
    
    user = [timeline lastStatus].user;
    [userCell.userView setUser:user];
    
    int count = [ary count];
    if (count > 8) count = 8;
    for (int i = 0; i < count; ++i) {
        [insertIndexPath addObject:[NSIndexPath indexPathForRow:indexOfLoadCell + i inSection:0]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)followDidRequest:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;
    
    if (sender.hasError) {
        [loadCell setType:MSG_TYPE_REQUEST_FOLLOW];
        [sender alert];
        return;
    }    
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [loadCell setType:MSG_TYPE_REQUEST_FOLLOW_SENT];
        loadCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

// UserCell delegate
//
- (void)toggleFavorite:(BOOL)favorited status:(Status*)sts
{
    int index = [timeline indexOfObject:sts];
    if (index < 0) return;
    UserTimelineCell* cell = (UserTimelineCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0]];
    [cell toggleFavorite:favorited];
}

- (void)userDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;    
    if (sender.hasError) {
        [sender alert];
        return;
    }
    
    NSDictionary *dic = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;

        user = [User userWithJsonDictionary:dic];
        [userCell.userView setUser:user];
        [userCell.userView setNeedsDisplay];
        
        [self.tableView reloadData];
    }
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if ([self tabBarController].selectedIndex == TWEET_TYPE_MESSAGES) {
        [postView editDirectMessage:screenName];
    }
    else {
        [postView reply:screenName];
    }
}

- (void) removeStatus:(Status*)status
{
    [timeline removeStatus:status];
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return false;
    
    if (twitterClient) return false;
    
    if ([TwitterFonAppDelegate isMyScreenName:screenName]) {
        Status* sts = [timeline statusAtIndex:indexPath.row - 1];
        return (sts) ? true : false;
    }
    else {
        return false;
    }
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
    forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Status* sts = [timeline statusAtIndex:indexPath.row - 1];
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        TwitterClient* client = [[TwitterClient alloc] initWithTarget:appDelegate action:@selector(tweetDidDelete:obj:)];
        client.context = [sts retain];
        [timeline removeStatus:sts];
        
        UIViewController *c = [self.navigationController.viewControllers objectAtIndex:0];
        
        if ([c respondsToSelector:@selector(removeStatus:)]) {
            [c removeStatus:sts];
        }
        
        [client destroy:sts];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [self.navigationItem setHidesBackButton:editing animated:animated];
    [super setEditing:editing animated:animated];
}

@end

