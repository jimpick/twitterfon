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
    [DirectMessage getConversation:msg.senderId messages:messages all:false];
    
    return self;
}

 - (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = nil;
 }
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 }
 */
/*
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 }
 */

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"ChatBubble";
    
    ChatBubbleCell *cell = (ChatBubbleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ChatBubbleCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    DirectMessage *dm = [messages objectAtIndex:indexPath.row];

    [cell setMessage:dm isOwn:dm.senderId != firstMessage.senderId];
    cell.text = dm.text;
    cell.font = [UIFont systemFontOfSize:16];
//    cell.image = [[TwitterFonAppDelegate getAppDelegate].imageStore getProfileImage:dm.profileImageUrl delegate:dm];
    // Configure the cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

- (void)postTweet:(id)sender
{
    PostViewController* postView = [TwitterFonAppDelegate getAppDelegate].postView;
    [postView editDirectMessage:self.navigationItem.title];
}

@end

