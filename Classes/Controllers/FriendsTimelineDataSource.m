//
//  FriendsTimelineDataSource.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FriendsTimelineDataSource.h"
#import "TwitterFonAppDelegate.h"
#import "UserViewController.h"

#import "MessageCell.h"
#import "TimeUtils.h"
#import "DBConnection.h"

static UIAlertView* sAlert = nil;

@interface NSObject (TimelineViewControllerDelegate)
- (void)timelineDidUpdate:(FriendsTimelineDataSource*)sender count:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate:(FriendsTimelineDataSource*)sender position:(int)position;
@end

@implementation FriendsTimelineDataSource

@synthesize timeline;
@synthesize contentOffset;

- (id)initWithController:(UITableViewController*)aController messageType:(MessageType)type
{
    [super init];
    
    controller  = aController;
    messageType = type;
    [loadCell setType:MSG_TYPE_LOAD_FROM_DB];
    isRestored = ([timeline restore:messageType all:false] < 20) ? true : false;
    return self;
}

- (void)dealloc {
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [timeline countMessages];
    return (isRestored) ? count : count + 1;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m ? m.cellHeight : 78;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MessageCell* cell = [timeline getMessageCell:tableView atIndex:indexPath.row];
    if (cell) {
        [cell.profileImage setImage:[imageStore getImage:cell.message.user.profileImageUrl delegate:controller] forState:UIControlStateNormal];
        [cell update:MSG_CELL_TYPE_NORMAL];
        return cell;
    }
    else {
        return loadCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    
    if (m) {
        // Display user view
        //
        UserViewController* userView = [[[UserViewController alloc] initWithMessage:m] autorelease];
        [[controller navigationController] pushViewController:userView animated:TRUE];
    }      
    else {
        // Restore tweets from DB
        //
        int count = [timeline restore:messageType all:true];
        isRestored = true;
        
        NSMutableArray *newPath = [[[NSMutableArray alloc] init] autorelease];
        
        [tableView beginUpdates];
        // Avoid to create too many table cell.
        if (count > 0) {
            if (count > 2) count = 2;
            for (int i = 0; i < count; ++i) {
                [newPath addObject:[NSIndexPath indexPathForRow:i + indexPath.row inSection:0]];
            }        
            [tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationTop];
        }
        else {
            [newPath addObject:indexPath];
            [tableView deleteRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationLeft];
        }
        [tableView endUpdates];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}


- (void)getTimeline
{
    if (twitterClient) return;
	twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(timelineDidReceive:messages:)];
    
    insertPosition = 0;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];

    int since_id = 0;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    for (int i = 0; i < [timeline countMessages]; ++i) {
        Message *m = [timeline messageAtIndex:i];
        if ([m.user.screenName caseInsensitiveCompare:username] != NSOrderedSame) {
            since_id = m.messageId;
            break;
        }
    }
    
    if (since_id) {
        [param setObject:[NSString stringWithFormat:@"%d", since_id] forKey:@"since_id"];
        [param setObject:@"200" forKey:@"count"];
    }
    
    [twitterClient getTimeline:messageType params:param];
}

- (void)timelineDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
   
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
    
    int unread = 0;
    LOG(@"Received %d messages", [ary count]);
    
    Message *lastMessage = [timeline lastMessage];
    if ([ary count]) {
        sqlite3* database = [DBConnection getSharedDatabase];
        char *errmsg; 
        sqlite3_exec(database, "BEGIN", NULL, NULL, &errmsg); 
        
        // Add messages to the timeline
        for (int i = [ary count] - 1; i >= 0; --i) {
            NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            sqlite_int64 messageId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
            if (![Message isExists:messageId type:messageType]) {
                Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:messageType];
                if (m.createdAt < lastMessage.createdAt) {
                    // Ignore stale message
                    continue;
                }
                [m insertDB];
                m.unread = true;
                
                [timeline insertMessage:m atIndex:insertPosition];
                ++unread;
				
               	[imageStore getImage:m.user.profileImageUrl delegate:controller];
            }
        }
        
        sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg); 
    }

    if ([controller respondsToSelector:@selector(timelineDidUpdate:count:insertAt:)]) {
        [controller timelineDidUpdate:self count:unread insertAt:insertPosition];
	}
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    
    if ([controller respondsToSelector:@selector(timelineDidFailToUpdate:position:)]) {
        [controller timelineDidFailToUpdate:self position:insertPosition];
    }
    
    if (sender.statusCode == 401) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate openSettingsView];
    }

    //
    // Save alert view to static pointer to avoid displaying alert view many times at the same time.
    //
    if (sAlert) return;
    
    sAlert = [[UIAlertView alloc] initWithTitle:error
                                        message:detail
                                       delegate:self
                              cancelButtonTitle:@"Close"
                              otherButtonTitles: nil];
    [sAlert show];	
    [sAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonInde
{
    sAlert = nil;
}

@end
