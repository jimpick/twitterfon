//
//  UserTimelineController.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserTimelineController.h"
#import "TwitterFonAppDelegate.h"
#import "MessageCell.h"

@implementation UserTimelineController

@synthesize message;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
        timeline = nil;
        isTimelineLoaded = false;
	}
	return self;
}

- (void)dealloc {
    [timeline release];
	[super dealloc];
}

- (void)setMessage:(Message *)aMessage
{
    // Reset timeline if needed
    //
    if (message && message.user.userId != aMessage.user.userId) {
        NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        [imageStore releaseImage:url];
        [timeline release];
        isTimelineLoaded = false;
        timeline = nil;
    }

    // This operation copy a message object
    [message release];
    message = [aMessage copy];
    message.type = MSG_TYPE_USER;
    [message updateAttribute];
    [self.tableView reloadData];
    self.title = message.user.screenName;    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isTimelineLoaded) {
        return [timeline countMessages] + 1;
    }
    else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 113;
    }
    else if (!isTimelineLoaded) {
        if (indexPath.row == 1) {
            return message.cellHeight;
        }
        else if (indexPath.row >= 2) {
            return 48;
        }
    }
    else {
        return [timeline messageAtIndex:indexPath.row - 1].cellHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0) {
        NSString *url = [message.user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        userCell.image = [imageStore getImage:url delegate:self];
        [userCell update:message delegate:self];
        return userCell;
    }
    else if (!isTimelineLoaded) {
        if (indexPath.row == 1) {
        
            MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
            if (!cell) {
                cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
            }
            cell.message = message;
            [cell update:MSG_TYPE_USER delegate:self];

            return cell;
        }
        else if (indexPath.row == 2) {
            LoadCell * cell =  (LoadCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadCell"];
            if (!cell) {
                cell = [[[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"] autorelease];
            }
            return cell;
        }
    }
    else {
        MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
        if (!cell) {
            cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
        }

        cell.message = [timeline messageAtIndex:indexPath.row - 1];
        [cell update:MSG_TYPE_USER delegate:self];
        return cell;
    }

    // won't come here.
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Load user timeline
    //
    if (indexPath.row == 2 && !isTimelineLoaded) {
        timeline = [[Timeline alloc] init];
        timeline.delegate = self;
        [timeline update:MSG_TYPE_USER userId:message.user.userId];
    }
}

// UserCell delegate
//
- (void)didTouchURL:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:message.user.url on:[self navigationController]];
}

- (void)viewDidLoad {
	[super viewDidLoad];
#if 0
    UIImage *image = [UIImage imageNamed:@"postbutton.png"];
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithImage:image 
                                                                   style:UIBarButtonItemStylePlain 
                                                                  target:self
                                                                  action:@selector(postTweet:)];
#endif    
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
    self.navigationItem.rightBarButtonItem = postButton;

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
    
    NSString *msg = [NSString stringWithFormat:@"@%@ ", message.user.screenName];
    
    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithString:msg];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
    if (timeline) {
        [timeline cancel];
    }
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

- (void)timelineDidUpdate:(int)count
{
    isTimelineLoaded = true;
    if (!self.view.hidden) {
        NSMutableArray *insertIndexPath = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *deleteIndexPath = [[[NSMutableArray alloc] init] autorelease];
        
        // Replace message if the current message is not latest one.
        //
        BOOL needReplaceMessage = ([timeline messageAtIndex:0].messageId != message.messageId);
        int i;
       
        for (i = (needReplaceMessage) ? 1 : 2 ; i <= 2; ++i) {
            [deleteIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        //
        // Avoid to create too many table cell.
        //
        if (count > 8) count = 8;
        for (int i = (needReplaceMessage) ? 1 : 2; i <= count; ++i) {
            [insertIndexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertIndexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView deleteRowsAtIndexPaths:deleteIndexPath withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];    
    }
}
@end

