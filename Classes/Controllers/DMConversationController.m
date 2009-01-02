//
//  DMConversationController.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "DMConversationController.h"
#import "DirectMessage.h"
#import "ColorUtils.h"
#import "ChatBubbleCell.h"

@implementation DMConversationController

- (id)initWithMessage:(DirectMessage*)msg
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.navigationItem.title = msg.senderScreenName;
    self.tableView.separatorColor = [UIColor conversationBackground];
    self.tableView.backgroundColor = [UIColor conversationBackground];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
    self.navigationItem.rightBarButtonItem = button;

//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    messages = [[NSMutableArray alloc] init];
    firstMessage = msg;
    [DirectMessage getConversation:msg.senderId messages:messages offset:0];
    isFirstTime = true;
    
    return self;
}

 - (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
    [self.tableView reloadData];
    if (isFirstTime) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[messages count] - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:false];
        isFirstTime = false;
    }
}

- (void)dealloc {
    [messages release];
    [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DirectMessage *dm = [messages objectAtIndex:indexPath.row];
    float ret = dm.textRect.size.height + 5 + 5 + 5; // bubble height
    if (dm.cellType == TWEET_CELL_TYPE_TIMESTAMP) {
        return 26;
    }
    else {
        return ret + 5;
    }

//    ret += (dm.needTimestamp) ? 24 : 4;
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DirectMessage *dm = [messages objectAtIndex:indexPath.row];
    
    ChatBubbleCell *cell = (ChatBubbleCell*)[tableView dequeueReusableCellWithIdentifier:@"ChatBubble"];
    if (cell == nil) {
        cell = [[[ChatBubbleCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ChatBubble"] autorelease];
    }
    
    [cell setMessage:dm isOwn:dm.senderId != firstMessage.senderId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)postTweet:(id)sender
{
    PostViewController* postView = [TwitterFonAppDelegate getAppDelegate].postView;
    [postView editDirectMessage:self.navigationItem.title];
}

- (void)postViewAnimationDidFinish
{
    if (self.navigationController.topViewController != self) return;

    NSIndexPath *path = [NSIndexPath indexPathForRow:[messages count]-1 inSection:0];
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

