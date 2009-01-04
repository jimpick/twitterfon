//
//  FavoritesViewController.m
//  TwitterFon
//
//  Created by kaz on 1/3/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "FavoritesViewController.h"
#import "ColorUtils.h"
#import "TwitterClient.h"
#import "Timeline.h"
#import "TimelineCell.h"
#import "TweetViewController.h"
#import "LoadCell.h"
#import "DBConnection.h"
#import "TwitterFonAppDelegate.h"

@implementation FavoritesViewController

- (void)awakeFromNib
{
    timeline = [[Timeline alloc] init];
}

- (void)viewDidLoad
{
    if (timeline == nil) {
        timeline = [[Timeline alloc] init];
    }
    if (loadCell == nil) {
        loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
        if (screenName) {
            [loadCell setType:MSG_TYPE_LOAD_FROM_WEB];
        }
        else {
            [loadCell setType:MSG_TYPE_LOAD_FROM_DB];
            [self restore:false];

            
        }
        [self reload:nil];
    }
}

- (void) dealloc
{
    [loadCell release];
    [timeline release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.tableView setContentOffset:contentOffset animated:false];
    [self.tableView reloadData];
    
    if (screenName == nil) {
        self.navigationController.navigationBar.tintColor = [UIColor navigationColorForTab:3];
    }
    self.tableView.separatorColor = [UIColor lightGrayColor]; 
    
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

//
// Public methods
//
- (void)loadTimeline:(NSString*)aScreenName
{
    screenName = aScreenName;
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s favorites", screenName];
}

- (int)restore:(BOOL)all
{
    Statement *stmt = [DBConnection statementWithQuery:"SELECT * FROM statuses WHERE favorited = 1 ORDER BY id DESC LIMIT ? OFFSET ?"];
    
    [stmt bindInt32:(all) ? 200 : 20            forIndex:1];
    [stmt bindInt32:[timeline countStatuses]    forIndex:2];
    
    int count = 0;
    while ([stmt step] == SQLITE_ROW) {
        Status* sts = [Status initWithStatement:stmt type:TWEET_TYPE_FAVORITES];
        [timeline appendStatus:sts];
        ++count;
    }
    isRestored = all;
    return count;
}


- (IBAction) reload:(id) sender
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    
    if (twitterClient) return;
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(favoritesDidReceive:obj:)];
    [twitterClient favorites:screenName page:1];
    
}

- (void) updateFavorite:(Status*)status
{
    if (status.favorited) {
        Status *newStatus = [status copy];
        newStatus.cellType = TWEET_CELL_TYPE_NORMAL;
        newStatus.type = TWEET_TYPE_FAVORITES;
        newStatus.unread = false;
        [newStatus updateAttribute];
        [timeline appendStatus:newStatus];
    }
    else {
        [timeline removeStatus:status];
    }
    [timeline sortByDate];
    [self.tableView reloadData];
}

- (void) removeStatus:(Status*)status
{
    [timeline removeStatus:status];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [timeline countStatuses];
    return (isRestored) ? count : count + 1;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status* sts = [timeline statusAtIndex:indexPath.row];
    return (sts) ? sts.cellHeight : 78;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TimelineCell* cell = [timeline getTimelineCell:tableView atIndex:indexPath.row];
    if (cell) {
        return cell;
    }
    else {
        return loadCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status* sts = [timeline statusAtIndex:indexPath.row];
    
    if (sts) {
        // Display user view
        //
        TweetViewController* tweetView = [[[TweetViewController alloc] initWithMessage:sts] autorelease];
        [self.navigationController pushViewController:tweetView animated:TRUE];
    }      
    else if (screenName) {
        if (twitterClient) return;
        [loadCell.spinner startAnimating];
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(favoritesDidReceive:obj:)];
        int page = ([timeline countStatuses] / 20) + 1;
        [twitterClient favorites:screenName page:page];
    }
    else {
        // Restore tweets from DB
        //
        int count = [self restore:true];
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


//
// TimelineDelegate
//
- (void)favoritesDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    self.navigationItem.leftBarButtonItem.enabled = true;
    
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    
    if (sender.hasError) {
        [sender alert];
    }
    
    if (obj == nil) {
        return;
    }
    
    NSArray *ary = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        ary = (NSArray*)obj;
        if ([ary count] == 0) return;
    }
    else {
        return;
    }
    
    // Add messages to the timeline
    for (int i = 0; i < [ary count]; ++i) {
        NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        if (screenName) {
            Status* sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i] type:TWEET_TYPE_FAVORITES];
            sts.unread = false;
            [timeline appendStatus:sts];
            if ([TwitterFonAppDelegate isMyScreenName:screenName]) {
                [sts insertDB];
            }
        }
        else {
            sqlite_int64 statusId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
            Status* sts = [Status statusWithId:statusId];
            if (sts) {
                sts.favorited = true;
                [sts updateFavoriteState];
            }
            else {
                Status* sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i] type:TWEET_TYPE_FAVORITES];
                sts.unread = false;
                [sts insertDB];
            }
        }
    }
    if (screenName == nil) {
        [timeline removeAllStatuses];
        [self restore:isRestored];
    }
    [self.tableView reloadData];
}


@end

