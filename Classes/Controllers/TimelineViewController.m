//
//  FriendsTimelineController.m
//  TwitterFon
//
//  Created by kaz on 10/29/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineViewDataSource.h"
#import "TwitterFonAppDelegate.h"
#import "ColorUtils.h"
#import "MessageCell.h"
#import "LoadCell.h"

@interface TimelineViewController (Private)
- (void)didLeaveTab:(UINavigationController*)navigationController;
@end


@implementation TimelineViewController

//
// UIViewController methods
//
- (void)viewDidLoad
{
    if (!isLoaded) {
        [self loadTimeline];
    }
    self.tableView.dataSource = currentDataSource;
    self.tableView.delegate   = currentDataSource;
    [self navigationController].tabBarItem.badgeValue = nil;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.tableView setContentOffset:contentOffset animated:false];
    [self.tableView reloadData];
    self.tableView.scrollsToTop = true;
    self.navigationController.navigationBar.tintColor = [UIColor navigationColorForTab:tab];
    self.tableView.separatorColor = [UIColor lightGrayColor]; 
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    if (stopwatch) {
        LAP(stopwatch, @"viewDidAppear");
        [stopwatch release];
        stopwatch = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    contentOffset = self.tableView.contentOffset;
}

- (void)viewDidDisappear:(BOOL)animated 
{
}

- (void)didReceiveMemoryWarning 
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDelegate.selectedTab != [self navigationController].tabBarItem.tag) {
        [super didReceiveMemoryWarning];
    }
}

//
// Public methods
//
- (void)loadTimeline
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    if (!(username == nil || password == nil ||
          [username length] == 0 || [password length] == 0)) {
        self.navigationItem.leftBarButtonItem.enabled = false;
        [currentDataSource getTimeline];
    }
    isLoaded = true;
}

- (void)restoreAndLoadTimeline:(BOOL)load
{
    stopwatch = [[Stopwatch alloc] init];
    tab       = [self navigationController].tabBarItem.tag;
    timelineDataSource = [[TimelineViewDataSource alloc] initWithController:self messageType:tab];
    currentDataSource = timelineDataSource;
    if (load) [self loadTimeline];

}

- (IBAction) reload: (id) sender
{
    self.navigationItem.leftBarButtonItem.enabled = false;
    [currentDataSource getTimeline];
}

- (IBAction) segmentDidChange:(id)sender
{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    if (control.selectedSegmentIndex == 0) {
        currentDataSource         = timelineDataSource;
        self.tableView.dataSource = timelineDataSource;
        self.tableView.delegate   = timelineDataSource;
    }
    else {
        if (sentMessageDataSource == nil) {
            sentMessageDataSource = [[TimelineViewDataSource alloc] initWithController:self messageType:MSG_TYPE_SENT];
            [sentMessageDataSource getTimeline];
        }
        currentDataSource         = sentMessageDataSource;
        self.tableView.dataSource = sentMessageDataSource;
        self.tableView.delegate   = sentMessageDataSource;
    }
    [self didLeaveTab:self.navigationController];
    [self.tableView reloadData];
}

- (void)postViewAnimationDidFinish
{
    if (tab == TAB_FRIENDS && self.navigationController.topViewController == self) {
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
    if (tab == TAB_FRIENDS) {
        Message *message = [Message messageWithJsonDictionary:dic type:MSG_TYPE_FRIENDS];
        [currentDataSource.timeline insertMessage:message atIndex:0];
    }
    else {
        //
        //  Do not come here anymore
    }
}


//
// TwitterFonApPDelegate delegate
//
- (void)didLeaveTab:(UINavigationController*)navigationController
{
    navigationController.tabBarItem.badgeValue = nil;
    for (int i = 0; i < [currentDataSource.timeline countMessages]; ++i) {
        Message* m = [currentDataSource.timeline messageAtIndex:i];
        m.unread = false;
    }
    unread = 0;
}


- (void) removeMessage:(Message*)message
{
    [currentDataSource.timeline removeMessage:message];
    [self.tableView reloadData];
}

- (void) updateFavorite:(Message*)message
{
    [currentDataSource.timeline updateFavorite:message];
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
- (void)timelineDidUpdate:(int)count insertAt:(int)position
{
    self.navigationItem.leftBarButtonItem.enabled = true;
    if (count) {
        unread += count;
        [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];
    }
 
    if (self.navigationController.tabBarController.selectedIndex == tab &&
        self.navigationController.topViewController == self) {
        
        [self.tableView beginUpdates];
        
        if (position) {
            NSMutableArray *deletion = [[[NSMutableArray alloc] init] autorelease];
            [deletion addObject:[NSIndexPath indexPathForRow:position inSection:0]];
            [self.tableView deleteRowsAtIndexPaths:deletion withRowAnimation:UITableViewRowAnimationBottom];
        }
        if (count != 0) {
            NSMutableArray *insertion = [[[NSMutableArray alloc] init] autorelease];
            
            // Avoid to create too many table cell.
            if (count > 8) count = 8;
            for (int i = 0; i < count; ++i) {
                [insertion addObject:[NSIndexPath indexPathForRow:position + i inSection:0]];
            }        
            [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationTop];
        }
        
        [self.tableView endUpdates];
    }
}

- (void)timelineDidFailToUpdate:(int)position
{
    self.navigationItem.leftBarButtonItem.enabled = true;
    LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]];
    if ([cell isKindOfClass:[LoadCell class]]) {
        [cell.spinner stopAnimating];
    }
}
@end

