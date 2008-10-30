//
//  TimelieViewController.m
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TimelineViewDataSource.h"
#import "TimelineViewController.h"
#import "TwitterFonAppDelegate.h"
#import "PostViewController.h"
#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "DBConnection.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)timelineDidUpdate:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate:(int)position;
- (void)searchDidLoad:(int)count insertAt:(int)insertAt;
- (void)noSearchResult;
- (void)timelineDidFailToLoad;
@end

@implementation TimelineViewDataSource

@synthesize timeline;
@synthesize query;

- (id)initWithController:(UITableViewController*)aController tag:(int)aTag
{
    [super init];
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    imageStore = appDelegate.imageStore;
    controller = aController;
    tag        = aTag;
    timeline   = [[Timeline alloc] initWithDelegate:controller];
    [timeline restore:tag all:false];
    
    return self;
}

- (void)dealloc {
    [query release];
    [userTimeline release];
    [timeline release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [timeline countMessages];
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Message* message = [timeline messageAtIndex:indexPath.row];
    
    if (message.type <= MSG_TYPE_LOAD_FROM_WEB) {
        LoadCell * cell =  (LoadCell*)[tableView dequeueReusableCellWithIdentifier:@"LoadCell"];
        if (!cell) {
            cell = [[[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"] autorelease];
        }
        [cell setType:message.type];
        return cell;
    }

	MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
	if (!cell) {
		cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
	}
    
	cell.message = message;
    if (message.type > MSG_TYPE_LOAD_FROM_WEB) {
        [cell.profileImage setImage:[imageStore getImage:message.user.profileImageUrl delegate:self] forState:UIControlStateNormal];
    }
    
    cell.contentView.backgroundColor = (message.unread) ? [UIColor cellColorForTab:tag] : [UIColor whiteColor];
    if (tag == TAB_FRIENDS && message.hasReply) {
        cell.contentView.backgroundColor = [UIColor cellColorForTab:TAB_REPLIES];
    }

    [cell update:tag delegate:self];

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    
    // Restore tweets from DB
    //
    if (m.type == MSG_TYPE_LOAD_FROM_DB) {
        int count = [timeline restore:tag all:true];
        
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
    //
    // More search
    //
    else if (m.type == MSG_TYPE_LOAD_FROM_WEB) {
        LoadCell *cell = (LoadCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell.spinner startAnimating];
        [self search];
    }
    //
    // Display user timeline
    //
    else {
        if (userTimeline == nil) {
            userTimeline = [[UserTimelineController alloc] initWithNibName:@"UserView" bundle:nil];
            userTimeline.parent = self;
        }
        [userTimeline setMessage:m];
        
        [[controller navigationController] pushViewController:userTimeline animated:true];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}


- (void)getTimeline:(MessageType)type page:(int)page insertAt:(int)pos
{
	TwitterClient* client = [[TwitterClient alloc] initWithTarget:self action:@selector(timelineDidReceive:messages:)];
    
    insertPosition = pos;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (page == 1) {
        since_id = 0;
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        for (int i = 0; i < [timeline countMessages]; ++i) {
            Message *m = [timeline messageAtIndex:i];
            if ([m.user.screenName compare:username] != NSOrderedSame) {
                since_id = m.messageId;
                break;
            }
        }
        
        if (since_id) {
            [param setObject:[NSString stringWithFormat:@"%d", since_id] forKey:@"since_id"];
            [param setObject:@"200" forKey:@"count"];
        }
    }
    else {
        [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    [client getTimeline:type params:param];
}

- (void)timelineDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
	[sender autorelease];
    
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
    
    BOOL noMoreRead = FALSE;
    int unread = 0;
    LOG(@"Received %d messages", [ary count]);
    
    if ([ary count]) {
        INIT_STOPWATCH(s);
        sqlite3* database = [DBConnection getSharedDatabase];
        char *errmsg; 
        sqlite3_exec(database, "BEGIN", NULL, NULL, &errmsg); 
        
        // Add messages to the timeline
        for (int i = [ary count] - 1; i >= 0; --i) {
            sqlite_int64 messageId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
            if (![Message isExist:messageId type:tag]) {
                Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:tag];
                m.unread = true;
                
                [timeline insertMessage:m atIndex:insertPosition];
                ++unread;
				
               	[imageStore getImage:m.user.profileImageUrl delegate:controller];
            }
            else if (messageId <= since_id) {
                noMoreRead = TRUE;
            }
        }
        
        sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg); 
        LAP(s, @"Data inserted");
    }
#if 0
    if ([ary count] == 20 && !noMoreRead && ++page <= 10) {
        [timeline insertMessage:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_WEB page:page] atIndex:insertPosition + unread];
    }
#endif
    if ([controller respondsToSelector:@selector(timelineDidUpdate:insertAt:)]) {
        [controller timelineDidUpdate:unread insertAt:insertPosition];
	}

    return;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
    if ([controller respondsToSelector:@selector(timelineDidFailToLoad)]) {
        [controller timelineDidFailToLoad];
    }
	[sender autorelease];
}

- (void)search
{
    int page = ([timeline countMessages] / 15) + 1;
    insertPosition = [timeline countMessages] - 1;
    if (insertPosition < 0) insertPosition = 0;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (latitude == 0 && longitude == 0) {
        [param setObject:self.query forKey:@"q"];
    }
    else {
        [param setObject:[NSString stringWithFormat:@"%f,%f,%dmi", latitude, longitude, 5] forKey:@"geocode"];
    }
    if (page) {
        [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }

    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(searchResultDidReceive:messages:)];
    [client search:param];
}

- (void)search:(NSString*)aQuery
{ 
    [timeline removeAllMessages];
    self.query = aQuery;
    latitude = longitude = 0;
    [self search];
}

- (void)geocode:(float)aLatitude longitude:(float)aLongitude
{
    latitude  = aLatitude;
    longitude = aLongitude;
    [self search];
}

- (void)searchResultDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    if (![obj isKindOfClass:[NSDictionary class]]) {
        [controller noSearchResult];
    }
    
    NSDictionary *dic = (NSDictionary*)obj;
        
    NSArray *array = (NSArray*)[dic objectForKey:@"results"];

    if ([array count] == 0) {
        [controller noSearchResult];
        return;
    }
    
    if ([timeline lastMessage].type == MSG_TYPE_LOAD_FROM_WEB) {
        [timeline removeLastMessage];
    }
    
    // Add messages to the timeline
    for (int i = 0; i < [array count]; ++i) {
        Message* m = [Message messageWithSearchResult:[array objectAtIndex:i]];
        [timeline appendMessage:m];
        [imageStore getImage:m.user.profileImageUrl delegate:controller];
    }
    
    [timeline appendMessage:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_WEB page:1]];
    if ([controller respondsToSelector:@selector(searchDidLoad:insertAt:)]) {
        [controller searchDidLoad:[array count] insertAt:insertPosition];
    }

    [sender autorelease];
}

- (void)removeAllMessages
{
    [timeline removeAllMessages];
}

- (void) removeMessage:(Message*)message
{
    [timeline removeMessage:message];
}

- (void) updateFavorite:(Message*)message
{
    [timeline updateFavorite:message];
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
    
    [controller.navigationController.view addSubview:postView.view];
    [postView startEditWithString:msg];
}

- (void)didTouchLinkButton:(NSString*)url
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [appDelegate openWebView:url on:[controller navigationController]];
}

@end
