//
//  FriendsTimelineController.m
//  TwitterFon
//
//  Created by kaz on 10/29/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DMTimelineController.h"
#import "DMConversationController.h"
#import "DirectMessage.h"
#import "DirectMessageCell.h"
#import "TwitterFonAppDelegate.h"
#import "DBConnection.h"
#import "Tweet.h"
#import "LoadCell.h"
#import "TwitterClient.h"
#import "ColorUtils.h"

// sort function of DM timeline
//
NSInteger sortByDate(id a, id b, void *context)
{
    DirectMessage* dma = (DirectMessage*)a;
    DirectMessage* dmb = (DirectMessage*)b;
    int diff = dmb.createdAt - dma.createdAt;
    if (diff > 0)
        return 1;
    else if (diff < 0)
        return -1;
    else
        return 0;
}

@interface DMTimelineController(Private)
- (void)scrollToFirstUnread:(NSTimer*)timer;
- (void)getMessage:(BOOL)getSentMessage;
- (void)restoreMessage:(BOOL)restoreAll;
@end

@implementation DMTimelineController

- (void)awakeFromNib
{
    loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
    timeline = [[NSMutableArray alloc] init];
    messages = [[NSMutableDictionary alloc] init];
    [loadCell setType:MSG_TYPE_LOAD_FROM_DB];
}

//
// UIViewController methods
//
- (void)viewDidLoad
{
    if (!isLoaded) {
        [self loadTimeline];
    }
}

- (void) dealloc
{
    [twitterClient cancel];
    [twitterClient release];
    [loadCell release];
    [timeline release];
    [messages release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning 
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.selectedTab != [self navigationController].tabBarItem.tag) {
        [super didReceiveMemoryWarning];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.tableView setContentOffset:contentOffset animated:false];
    [self.tableView reloadData];
    self.navigationController.navigationBar.tintColor = [UIColor navigationColorForTab:TAB_MESSAGES];
    self.tableView.separatorColor = [UIColor lightGrayColor]; 
  
}

- (void)viewDidAppear:(BOOL)animated
{
    if (firstTimeToAppear) {
        firstTimeToAppear = false;
        [self scrollToFirstUnread:nil];
    }
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [timeline count];
    return (isRestored) ? count : count + 1;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [timeline count]) return 78;
    
    return 48 + 3 + 16;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [timeline count]) {
        return loadCell;
    }
    DirectMessage *dm = [timeline objectAtIndex:indexPath.row];
    
    DirectMessageCell *cell = (DirectMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"DirectMessage"];
    if (!cell) {
        cell = [[[DirectMessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DirectMessage"] autorelease];
    }
    [cell setMessage:dm];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   

    if (indexPath.row >= [timeline count]) {
        [self restoreMessage:true];
        isRestored = true;
        [tableView reloadData];
    }
    else {
        DirectMessage *dm = [timeline objectAtIndex:indexPath.row];
        DMConversationController *conv = [[[DMConversationController alloc] initWithMessage:dm] autorelease];
        [self.navigationController pushViewController:conv animated:true];
    }
}

//
// Public methods
//

- (void)loadTimeline
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (!(username == nil || password == nil ||
          [username length] == 0 || [password length] == 0)) {
        self.navigationItem.leftBarButtonItem.enabled = false;
        [self getMessage:false];
    }
    isLoaded = true;
}

- (void)restoreMessage:(BOOL)restoreAll
{
    isRestored = restoreAll;
    [timeline removeAllObjects];
    [messages removeAllObjects];
    [DirectMessage restore:timeline all:restoreAll];
    for (int i = 0; i < [timeline count]; ++i) {
        DirectMessage *dm = [timeline objectAtIndex:i];
        [messages setObject:dm forKey:[NSString stringWithFormat:@"%d", dm.senderId]];
    }    
}

- (void)restoreAndLoadTimeline:(BOOL)load
{
    firstTimeToAppear = true;
    [self restoreMessage:false];
    if (load) [self loadTimeline];
}

- (void)getMessage:(BOOL)getSentMessage
{
    if (twitterClient) return;
	twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(messageDidReceive:obj:)];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if ([timeline count]) {
        DirectMessage *dm = [timeline objectAtIndex:0];
        int since_id = dm.messageId;
    
        [param setObject:[NSString stringWithFormat:@"%d", since_id] forKey:@"since_id"];
        [param setObject:@"200" forKey:@"count"];
    }
    else {
        [param setObject:@"200" forKey:@"count"];
    }

    [twitterClient getTimeline:TWEET_TYPE_MESSAGES params:param];
    
    needToGetSentMessage = getSentMessage;
}

- (IBAction)reload:(id) sender
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    [self getMessage:true];
}

- (void)autoRefresh
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    [self getMessage:false];
    [self reload:nil];
}


- (NSArray*)examObject:(NSObject*)obj
{
    if (obj == nil) {
        return nil;
    }
    
    NSArray *ary = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        ary = (NSArray*)obj;
        NSLog(@"Received %d messages", [ary count]);
        return ary;
    }
    return nil;
}

- (void)messageDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = true;
    
    if (needToGetSentMessage) {
        self.navigationItem.leftBarButtonItem.enabled = false;
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(sentMessageDidReceived:obj:)];
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"200" forKey:@"count"];
        [twitterClient getTimeline:TWEET_TYPE_SENT params:nil];
    }
    
    NSArray *ary = [self examObject:obj];
    if (ary == nil) return;
    
    DirectMessage* lastDM = [timeline lastObject];
    if ([ary count] == 0) return;
    
    // Retrieve DM from JSON object then insert them
    sqlite3* database = [DBConnection getSharedDatabase];
    char *errmsg; 
    sqlite3_exec(database, "BEGIN", NULL, NULL, &errmsg); 

    for (int i = [ary count] - 1; i >= 0; --i) {
        NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        sqlite_int64 aId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
        if (![DirectMessage isExists:aId]) {
            DirectMessage* dm = [DirectMessage messageWithJsonDictionary:[ary objectAtIndex:i]];
            if (dm.createdAt < lastDM.createdAt) {
                // Ignore stale message
                continue;
            }
            [dm insertDB];
            dm.unread = true;
            [messages setObject:dm forKey:[NSString stringWithFormat:@"%d", dm.senderId]];
            ++unread;
        }
    }
    sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg); 
    
    [timeline release];
    timeline = [[messages allValues] mutableCopy];
    NSLog(@"Updated %d messages", [timeline count]);
    [timeline sortUsingFunction:sortByDate context:nil];
    
    [self.tableView reloadData];

    if (unread) {
        [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];    
    }
}

- (void)sentMessageDidReceived:(TwitterClient*)sender obj:(NSObject*)obj
{
    self.navigationItem.leftBarButtonItem.enabled = true;
    twitterClient = nil;
    
    NSArray *ary = [self examObject:obj];
    if (ary == nil) return;
    
    // Retrieve DM from JSON object then insert them
    sqlite3* database = [DBConnection getSharedDatabase];
    char *errmsg; 
    sqlite3_exec(database, "BEGIN", NULL, NULL, &errmsg); 
    
    for (int i = [ary count] - 1; i >= 0; --i) {
        NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        sqlite_int64 aId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
        if (![DirectMessage isExists:aId]) {
            DirectMessage* dm = [DirectMessage messageWithJsonDictionary:[ary objectAtIndex:i]];
            [dm insertDB];
        }
    }
    sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg); 
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = true;
    
    [[TwitterFonAppDelegate getAppDelegate] alert:error message:detail];
}


- (void)postViewAnimationDidFinish
{
    if (self.navigationController.topViewController != self) return;
    
    NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
        
}

- (void)postTweetDidSucceed:(Tweet*)status
{
    // TO BE IMPLEMENTED
}
//
// TwitterFonApPDelegate delegate
//
- (void)didLeaveTab:(UINavigationController*)navigationController
{
    navigationController.tabBarItem.badgeValue = nil;
    for (DirectMessage *dm in timeline) {
        dm.unread = false;
    }
    for (DirectMessage *dm in [messages allValues]) {
        dm.unread = false;
    }
    unread = 0;
}


- (void) removeMessage:(DirectMessage*)message
{
    [messages removeObjectForKey:[NSString stringWithFormat:@"%d", message.senderId]];
    [timeline removeObject:message];
    [self.tableView reloadData];
}

- (void)scrollToFirstUnread:(NSTimer*)timer
{
#if 0
    if (unread) {
        if (unread < [timeline count]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:unread inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionBottom animated:true];
        }
    }
#endif
}

@end

