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
#import "LinkViewController.h"
#import "PostViewController.h"
#import "UserTimelineController.h"

#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "DBConnection.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)timelineDidUpdate:(TimelineViewDataSource*)sender count:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate:(TimelineViewDataSource*)sender position:(int)position;
- (void)searchDidLoad:(int)count insertAt:(int)insertAt;
- (void)noSearchResult;
@end

@implementation TimelineViewDataSource

@synthesize timeline;
@synthesize query;
@synthesize contentOffset;

- (id)initWithController:(UITableViewController*)aController messageType:(MessageType)type
{
    [super init];
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    imageStore  = appDelegate.imageStore;
    controller  = aController;
    messageType = type;
    loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
    [loadCell setType:(messageType != MSG_TYPE_SEARCH_RESULT) ? MSG_TYPE_LOAD_FROM_DB : MSG_TYPE_LOAD_FROM_WEB];
    timeline   = [[Timeline alloc] initWithDelegate:controller];
    if (messageType != MSG_TYPE_SEARCH_RESULT) {
        isRestored = ([timeline restore:messageType all:false] < 20) ? true : false;
    }
    return self;
}

- (void)dealloc {
    [loadCell release];
    [query release];
    [timeline release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    tableView.separatorColor = [UIColor lightGrayColor]; 
    tableView.backgroundColor = [UIColor whiteColor];
    
    int count = [timeline countMessages];
    if (messageType == MSG_TYPE_SEARCH_RESULT) {
        return (count) ? count + 1 : 0;
    }else {
        return (isRestored) ? count : count + 1;
    }
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m ? m.cellHeight : 48;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Message* message = [timeline messageAtIndex:indexPath.row];
    
    if (message) {
        MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
        if (!cell) {
            cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
        }
        
        cell.message = message;
        [cell.profileImage setImage:[imageStore getImage:message.user.profileImageUrl delegate:controller] forState:UIControlStateNormal];
        cell.contentView.backgroundColor = (message.unread) ? [UIColor cellColorForTab:messageType] : [UIColor whiteColor];
        
        if (messageType == MSG_TYPE_FRIENDS && message.hasReply) {
            cell.contentView.backgroundColor = [UIColor cellColorForTab:TAB_REPLIES];
        }
        
        [cell update:messageType delegate:self];
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
        // Display user timeline
        //
        UserTimelineController* userTimeline = [[[UserTimelineController alloc] initWithNibName:nil bundle:nil] autorelease];
        [userTimeline setMessage:m];
        [[controller navigationController] pushViewController:userTimeline animated:true];
    }
    else {
        // Restore tweets from DB
        //
        if (loadCell.type == MSG_TYPE_LOAD_FROM_DB) {
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
        //
        // More search
        //
        else if (loadCell.type == MSG_TYPE_LOAD_FROM_WEB) {
            [loadCell.spinner startAnimating];
            [self searchSubstance:false];
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}


- (void)getTimeline
{
	TwitterClient* client = [[TwitterClient alloc] initWithTarget:self action:@selector(timelineDidReceive:messages:)];
    
    insertPosition = 0;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    int page = 1;
    if (page == 1) {
        since_id = 0;
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
    }
    else {
        [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }
    
    [client getTimeline:messageType params:param];
}

- (void)timelineDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
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
            sqlite_int64 messageId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
            if (![Message isExists:messageId type:messageType]) {
                Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:messageType];
                if (m.createdAt < lastMessage.createdAt) {
                    // Ignore stale message
                    continue;
                }
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
    
    [loadCell.spinner stopAnimating];
    
    if ([controller respondsToSelector:@selector(timelineDidFailToUpdate:position:)]) {
        [controller timelineDidFailToUpdate:self position:insertPosition];
    }
    
    if (sender.statusCode == 401) {
        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate openSettingsView];
    }
}

- (BOOL)searchSubstance:(BOOL)reload
{
    int page;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if (reload) {
        page = 0;
        insertPosition = 0;
        Message *m = [timeline messageAtIndex:0];
        if (!m) return false;
        since_id = m.messageId;
        [param setObject:[NSString stringWithFormat:@"%lld", since_id] forKey:@"since_id"];
    }
    else {
        since_id = 0;
        page = ([timeline countMessages] / 15) + 1;
        insertPosition = [timeline countMessages];
    }
    
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
    return true;
}

- (void)search:(NSString*)aQuery
{ 
    [timeline removeAllMessages];
    self.query = aQuery;
    latitude = longitude = 0;
    [self searchSubstance:false];
}

- (void)geocode:(float)aLatitude longitude:(float)aLongitude
{
    latitude  = aLatitude;
    longitude = aLongitude;
    [self searchSubstance:false];
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
    
    [loadCell.spinner stopAnimating];
    
    // Add messages to the timeline
    for (int i = [array count] - 1; i >= 0; --i) {
        Message* m = [Message messageWithSearchResult:[array objectAtIndex:i]];
        if ([timeline indexOfObject:m] == -1) {
            [timeline insertMessage:m atIndex:insertPosition];
            [imageStore getImage:m.user.profileImageUrl delegate:controller];
            if (since_id) {
                m.unread = true;
            }
        }

    }
    
    if ([controller respondsToSelector:@selector(searchDidLoad:insertAt:)]) {
        [controller searchDidLoad:[array count] insertAt:insertPosition];
    }
}

- (void)removeAllMessages
{
    [timeline removeAllMessages];
}

- (void)didTouchProfileImage:(MessageCell*)cell
{
    Message* m = cell.message;
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    NSString *msg;
    if (messageType == MSG_TYPE_MESSAGES) {
        msg = [NSString stringWithFormat:@"d %@ ", m.user.screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", m.user.screenName];
    }
    
    [postView startEditWithString:msg];
}

- (void)didTouchLinkButton:(Message*)message links:(NSArray*)array
{
    if ([array count] == 1) {
        NSString* url = [array objectAtIndex:0];
        NSRange r = [url rangeOfString:@"http://"];
        if (r.location != NSNotFound) {
            TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate openWebView:url on:[controller navigationController]];
        }
        else {
            UserTimelineController *userTimeline = [[[UserTimelineController alloc] initWithNibName:nil bundle:nil] autorelease];
            [userTimeline loadUserTimeline:[array objectAtIndex:0]];
            [[controller navigationController] pushViewController:userTimeline animated:true];
        }
    }
    else {
        [controller navigationController].navigationBar.tintColor = nil;

        LinkViewController* linkView = [[[LinkViewController alloc] init] autorelease];
        linkView.message = message;
        linkView.links   = array;
        [[controller navigationController] pushViewController:linkView animated:true];
    }
}

@end
