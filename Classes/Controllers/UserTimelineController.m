//
//  UserTimelineController.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserTimelineController.h"
#import "MessageCell.h"
#import "UserMessageCell.h"

@implementation UserTimelineController


- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
	}
    timeline = nil;
	return self;
}


- (void)dealloc {
    [timeline release];
	[super dealloc];
}

- (void)setMessage:(Message *)message image:(UIImage*)image
{
    // Reset timeline if needed
    //
    if (userCell.message && userCell.message.user.userId != message.user.userId) {
        [timeline release];
        timeline = nil;
    }
    
    userCell.message = message;
    userCell.profileImage.image = image;
    self.title = message.user.screenName;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (timeline) ? [timeline countMessages] + 1 : 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [userCell calcCellHeight];
    }
    else if (indexPath.row == 1) {
        return userCell.message.cellHeight;
    }
    else if (indexPath.row >= 2) {
        if (timeline) {

        }
        else {
            return 48;
        }
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.row == 0) {
        return userCell;
    }
    else if (timeline == nil) {
        if (indexPath.row == 1) {
        
            MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
            if (!cell) {
                cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
            }
            cell.message = userCell.message;
            [cell update:MSG_TYPE_USER delegate:delegate];

            return cell;
        }
        else if (indexPath.row == 2) {
            UserMessageCell * cell = [[[UserMessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Indicator"] autorelease];
            [cell setType:USER_CELL_LOAD_BUTTON];
            return cell;
        }
    }
    else {
        MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
        if (!cell) {
            cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
        }

        cell.message = [timeline messageAtIndex:indexPath.row - 1];
        [cell update:MSG_TYPE_USER delegate:delegate];
        return cell;
    }

    // won't come here.
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Load user timeline
    //
    if (indexPath.row == 2 && timeline == nil) {
        timeline = [[Timeline alloc] init];
        timeline.delegate = self;
        [timeline update:MSG_TYPE_USER userId:userCell.message.user.userId];
    }
}


- (void)viewDidLoad {
	[super viewDidLoad];
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
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
    userCell.profileImage.image = image;    
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
  
    if (!self.view.hidden) {
        NSMutableArray *indexPath = [[[NSMutableArray alloc] init] autorelease];
        
        // Replace message if the current message is not latest one.
        //
        BOOL needReplaceMessage = ([timeline messageAtIndex:0].messageId != userCell.message.messageId);
        int i;
       
        for (i = (needReplaceMessage) ? 1 : 2 ; i <= 2; ++i) {
            [indexPath removeObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        //
        // Avoid to create too many table cell.
        //
        if (count > 8) count = 8;
        for (int i = (needReplaceMessage) ? 1 : 2; i <= count; ++i) {
            [indexPath addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];    
    }
    
}
@end

