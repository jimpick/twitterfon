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
#import "DebugUtils.h"

// sort function of DM timeline
//
static NSInteger sortByDate(id a, id b, void *context)
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
- (void)loadMessages:(BOOL)loadSentMessage;
- (void)loadSentMessages;
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
        [self loadMessages:true];
    }
    else {
        [self loadSentMessages];
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
    
    DirectMessage *dm = [timeline objectAtIndex:indexPath.row];
    
    return dm.cellHeight;
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

- (void)loadMessages:(BOOL)loadSentMessage
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if ([username length] != 0 && [password length] != 0) {
        self.navigationItem.leftBarButtonItem.enabled = false;
        [self getMessage:loadSentMessage];
    }
    isLoaded = true;
}

- (void)loadSentMessages
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(sentMessageDidReceived:obj:)];

    sqlite_int64 since_id = [DirectMessage lastSentMessageId];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (since_id) {
        [param setObject:[NSString stringWithFormat:@"%lld", since_id] forKey:@"since_id"];
        [param setObject:@"200" forKey:@"count"];
    }
#if 0
    else {
        [param setObject:@"200" forKey:@"count"];
    }
#endif
    [twitterClient getTimeline:TWEET_TYPE_SENT params:param];
}   

- (void)restoreMessage:(BOOL)restoreAll
{
    isRestored = restoreAll;
    NSMutableArray *array = [NSMutableArray array];
    [DirectMessage restore:array all:restoreAll];
    for (int i = 0; i < [array count]; ++i) {
        DirectMessage *dm = [array objectAtIndex:i];
        NSString *ids = [NSString stringWithFormat:@"%d", dm.senderId];
        if (![messages objectForKey:ids]) {
            [messages setObject:dm forKey:ids];
            [timeline addObject:dm];
        }
    }    
    [timeline sortUsingFunction:sortByDate context:nil];
}

- (void)restoreAndLoadTimeline:(BOOL)load
{
    firstTimeToAppear = true;
    [self restoreMessage:false];
    if (load) [self loadMessages:false];
}

- (void)getMessage:(BOOL)getSentMessage
{
    if (twitterClient) return;
	twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(messageDidReceive:obj:)];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if ([timeline count]) {
        DirectMessage *dm = [timeline objectAtIndex:0];
        int since_id = dm.messageId;
    
        [param setObject:[NSString stringWithFormat:@"%lld", since_id] forKey:@"since_id"];
        [param setObject:@"200" forKey:@"count"];
    }
#if 0
    else {
        [param setObject:@"200" forKey:@"count"];
    }
#endif
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
        LOG(@"Received %d messages", [ary count]);
        return ary;
    }
    return nil;
}

- (void)messageDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = true;
    
    if (sender.hasError) {
        [sender alert];
        return;
    }
    
    if (needToGetSentMessage) {
        [self loadSentMessages];
    }
    
    NSArray *ary = [self examObject:obj];
    if (ary == nil) return;
    
    DirectMessage* lastDM = [timeline lastObject];
    if ([ary count] == 0) return;
    
    // Retrieve DM from JSON object then insert them
    [DBConnection beginTransaction];

    for (int i = [ary count] - 1; i >= 0; --i) {
        NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        sqlite_int64 aId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
        if (![DirectMessage isExists:aId]) {
            DirectMessage* dm = [DirectMessage messageWithJsonDictionary:[ary objectAtIndex:i]];
            [dm insertDB];
            if (dm.createdAt < lastDM.createdAt) {
                // Ignore stale message
                continue;
            }
            dm.unread = true;
            [messages setObject:dm forKey:[NSString stringWithFormat:@"%d", dm.senderId]];
            ++unread;
        }
    }
    [DBConnection commitTransaction];
    
    [timeline release];
    timeline = [[messages allValues] mutableCopy];
    LOG(@"Updated %d messages", [timeline count]);
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
    
    if (sender.hasError) {
        [sender alert];
        return;
    }
    
    NSArray *ary = [self examObject:obj];
    if (ary == nil) return;
    
    // Retrieve DM from JSON object then insert them
    [DBConnection beginTransaction];
    
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
    [DBConnection commitTransaction];
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
    if ([DirectMessage countMessages:message.senderId] == 0) {
        [messages removeObjectForKey:[NSString stringWithFormat:@"%d", message.senderId]];
        for (int i = 0; i < [timeline count]; ++i) {
            DirectMessage *dm = [timeline objectAtIndex:i];
            if (dm.senderId == message.senderId) {
                [timeline removeObjectAtIndex:i];
                break;
            }
        }
        [self.tableView reloadData];
    }
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

