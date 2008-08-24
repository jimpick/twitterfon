//
//  TimelieViewController.m
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TimelineViewController.h"
#import "TwitterFonAppDelegate.h"
#import "PostViewController.h"
#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)postTweetDidSucceedDelegate:(NSDictionary*)dic;
@end

@implementation TimelineViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    unread   = 0;
    tag      = [self navigationController].tabBarItem.tag;

    switch (tag) {
        case TAB_FRIENDS:
            self.tableView.separatorColor = [UIColor whiteColor];
            break;
            
        case TAB_REPLIES:
            self.tableView.separatorColor =  [UIColor whiteColor];
            self.tableView.backgroundColor = [UIColor repliesColor:false];
            break;
            
        case TAB_MESSAGES:
            self.tableView.separatorColor =  [UIColor whiteColor];
            self.tableView.backgroundColor = [UIColor messageColor:false];
    }
    [timeline restore:tag];
    [timeline update:tag];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
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
	return [timeline countMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
	Message* message = [timeline messageAtIndex:indexPath.row];
	if (!cell) {
		cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
	}
    
	cell.message = message;
    [cell.profileImage setImage:[imageStore getImage:message.user.profileImageUrl delegate:self] forState:UIControlStateNormal];

    if (tag == TAB_FRIENDS) {
        cell.contentView.backgroundColor = message.hasReply ?
            [UIColor repliesColor:message.unread] : [UIColor friendColor:message.unread];
    }
    else if (tag == TAB_REPLIES) {
        cell.contentView.backgroundColor = [UIColor repliesColor:message.unread];
    }
    else if (tag == TAB_MESSAGES) {
        cell.contentView.backgroundColor = [UIColor messageColor:message.unread];
    }

    [cell update:tag delegate:self];

	return cell;
}

- (void)didTouchLinkButton:(NSString*)url
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:url on:[self navigationController]];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

- (IBAction) post: (id) sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;

    [[self navigationController].view addSubview:postView.view];
    [postView startEdit];
}

- (IBAction) reload: (id) sender
{
    [timeline update:tag];
}


//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (userTimeline == nil) {
        userTimeline = [[UserTimelineController alloc] initWithNibName:@"UserView" bundle:nil];
    }
    Message *m = [timeline messageAtIndex:indexPath.row];
    [[self navigationController] pushViewController:userTimeline animated:true];
    [userTimeline setMessage:m];
}

- (void)didTouchProfileImage:(MessageCell*)cell
{
    Message* m = cell.message;
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;
    
    NSString *msg;
    if (tag == MSG_TYPE_MESSAGES) {
        msg = [NSString stringWithFormat:@"d %@ ", m.user.screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", m.user.screenName];
    }
    
    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithString:msg];
}

- (void)postViewAnimationDidFinish
{
    if (tag == TAB_FRIENDS && self.navigationController.topViewController == self) {
        //
        // Do animation if the controller displays friends timeline.
        //
        NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)postTweetDidSucceed:(NSDictionary*)dic
{
    if (tag == TAB_FRIENDS) {
        Message *message = [Message messageWithJsonDictionary:dic type:MSG_TYPE_FRIENDS];
        [timeline insertMessage:message];
    }
    else {
        //
        //  Do not come here anymore
    }
}

//
// TwitterFonApPDelegate delegate
//
- (void)didChangeSeletViewController:(UINavigationController*)navigationController
{
    navigationController.tabBarItem.badgeValue = nil;
    for (int i = 0; i < [timeline countMessages]; ++i) {
        Message* m = [timeline messageAtIndex:i];
        m.unread = false;
    }
    unread = 0;
}

//
// ImageStoreDelegate
//
- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

//
// TimelineDelegate
//
- (void)timelineDidReceiveNewMessage:(Message*)msg
{
	[imageStore getImage:msg.user.profileImageUrl delegate:self];
}

- (void)timelineDidUpdate:(int)count
{
    unread += count;
    [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];

    if (!self.view.hidden) {
        NSMutableArray *indexPath = [[[NSMutableArray alloc] init] autorelease];
        //
        // Avoid to create too many table cell.
        //
        if (count > 8) count = 8;
        for (int i = 0; i < count; ++i) {
            [indexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];    
    }

}
@end
