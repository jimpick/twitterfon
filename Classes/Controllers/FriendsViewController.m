//
//  FriendsViewController.m
//  TwitterFon
//
//  Created by kaz on 12/12/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "FriendsViewController.h"
#import "UserDetailViewController.h"
#import "LoadCell.h"
#import "FolloweeCell.h"

@implementation FriendsViewController

- (id)initWithScreenName:(NSString*)aName isFollowers:(BOOL)flag
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        hasMore = false;
        isFollowers = flag;
        screenName = [aName copy];
        friends = [[NSMutableArray array] retain];
        self.navigationItem.title = [NSString stringWithFormat:@"%@'s %@", aName, (isFollowers) ? @"followers" : @"friends"];
        page = 1;
        
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(friendsDidReceive:messages:)];
        [twitterClient getFriends:screenName page:page isFollowers:isFollowers];


        loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
        [loadCell setType:MSG_TYPE_LOAD_MORE_FRIENDS];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated 
{
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (void)dealloc {
    [screenName release];
    [loadCell release];
    [friends release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friends count] + ((hasMore) ? 1 : 0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == [friends count]) {
        return loadCell;
    }
    else {
        User *user = [friends objectAtIndex:indexPath.row];
        static NSString *CellIdentifier = @"FriendsCell";
        FolloweeCell *cell = (FolloweeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[FolloweeCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
        }
        [cell setUser:user];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == [friends count]) ? 78 : 51;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    if (indexPath.row == [friends count]) {
        if (twitterClient) return;
        
        [loadCell.spinner startAnimating];
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(friendsDidReceive:messages:)];
        [twitterClient getFriends:screenName page:page isFollowers:isFollowers];
    }
    else {
        User *user = [friends objectAtIndex:indexPath.row];
        UserDetailViewController *detailView = [[[UserDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
        detailView.user = user;
        [self.navigationController pushViewController:detailView animated:true];
    }
}

- (void)friendsDidReceive:(TwitterClient*)client messages:(NSObject*)obj
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    
    int prevCount = [friends count];
    
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
    
    if ([ary count] == 0) {
        hasMore = false;
        [self.tableView beginUpdates];
        NSIndexPath *path = [NSIndexPath indexPathForRow:[friends count] inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        return;
    }
    
    ++page;
    hasMore = true;
    
    // Add messages to the timeline
    for (int i = 0; i < [ary count]; ++i) {
        NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        User *user = [[User alloc] initWithJsonDictionary:dic];
        [friends addObject:user];
    }
    
    if (prevCount == 0) {
        [self.tableView reloadData];
    }
    else {
        int count = [ary count];
        if (count > 3) count = 3;
    
        NSMutableArray *newPath = [[[NSMutableArray alloc] init] autorelease];
        [self.tableView beginUpdates];
        for (int i = 0; i < count; ++i) {
            [newPath addObject:[NSIndexPath indexPathForRow:prevCount + i inSection:0]];
        }
        [self.tableView insertRowsAtIndexPaths:newPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];    
    }
    
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
}

@end

