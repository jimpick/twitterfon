//
//  DMConversationController.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "ConversationController.h"
#import "DMDetailViewController.h"
#import "DirectMessage.h"
#import "ColorUtils.h"
#import "ChatBubbleCell.h"

@implementation ConversationController

- (id)initWithMessage:(Tweet*)msg
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.navigationItem.title = msg.user.screenName;
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
    self.navigationItem.rightBarButtonItem = button;
    
    messages = [[NSMutableArray alloc] init];
    firstMessage = msg;
    int count = [firstMessage getConversation:messages];
    hasMore = (count == NUM_MESSAGE_PER_PAGE) ? true : false;
    
    loadCell = [[LoadEarlierMessageCell alloc] initWithDelegate:self];
    
    isFirstTime = true;
    
    return self;
}

- (void)viewDidLoad
{
    self.tableView.separatorColor = [UIColor conversationBackground];
    self.tableView.backgroundColor = [UIColor conversationBackground];
}

 - (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    [self.tableView reloadData];
    if (isFirstTime) {
        int pos = [messages count] - 1;
        if (hasMore) ++pos;
        NSIndexPath *path = [NSIndexPath indexPathForRow:pos inSection:0];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:false];
        isFirstTime = false;
    }
    else {
        [self.tableView setContentOffset:contentOffset animated:false];    
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
}

- (void)dealloc {
    [loadCell release];
    [messages release];
    [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [messages count] + (hasMore ? 1 : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    time_t prev = 0;
    
    int index = indexPath.row;
    
    if (hasMore) {
        if (index == 0) {
            return 46 + 10 + 1;
        }
        --index;
    }
    
    if (index - 1 >= 0) {
        Tweet *prevMsg = [messages objectAtIndex:index - 1];
        prev = prevMsg.createdAt;
    }
    
    Tweet *msg = [messages objectAtIndex:index];
    
    return [ChatBubbleCell calcCellHeight:msg interval:msg.createdAt - prev];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    int index = indexPath.row;
    if (hasMore) {
        if (index == 0) {
            return loadCell;
        }
        --index;
    }
    
    DirectMessage *dm = [messages objectAtIndex:index];
    
    ChatBubbleCell *cell = (ChatBubbleCell*)[tableView dequeueReusableCellWithIdentifier:@"ChatBubble"];
    if (cell == nil) {
        cell = [[[ChatBubbleCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ChatBubble"] autorelease];
    }
    
    BOOL isOwn = [TwitterFonAppDelegate isMyScreenName:dm.user.screenName];
    [cell setMessage:dm isOwn:isOwn];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int index = indexPath.row;
    if (hasMore) {
        if (index == 0) {
            return;
        }
        --index;
    }
    
    DirectMessage *dm = [messages objectAtIndex:index];
    if (dm.sender) {
        DMDetailViewController *c = [[[DMDetailViewController alloc] initWithMessage:dm] autorelease];
        [self.navigationController pushViewController:c animated:true];
    }
}

- (void)loadEarlierMessages:(id)sender
{
    int count = [firstMessage getConversation:messages];
    hasMore = (count > 0) ? true : false;
    if (count) {
        [self.tableView reloadData];
    }
    else {
        NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
   
}

- (void)removeMessage:(DirectMessage*)message
{
    [messages removeObject:message];
    [self.tableView reloadData];
}

- (void)postTweet:(id)sender
{
    PostViewController* postView = [TwitterFonAppDelegate getAppDelegate].postView;
    [postView editDirectMessage:self.navigationItem.title];
}

- (void)postViewAnimationDidFinish
{
    if (self.navigationController.topViewController != self) return;

    int pos = [messages count] - 1;
    if (hasMore) ++pos;
    NSIndexPath *path = [NSIndexPath indexPathForRow:pos inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:path];
    CGSize size = self.tableView.contentSize;
    CGPoint point = self.tableView.contentOffset;
    UITableViewRowAnimation anim = (size.height == point.y + self.tableView.bounds.size.height) ? 
        UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:anim];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:true];
    
}

- (void)sendMessageDidSucceed:(DirectMessage*)dm
{
    [messages addObject:dm];
}

@end

