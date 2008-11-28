//
//  SearchViewController.m
//  TwitterFon
//
//  Created by kaz on 10/24/08.
//  Copyright 2008 naan studio. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "SearchViewController.h"
#import "SearchHistoryViewController.h"
#import "LocationDistanceWindow.h"
#import "DBConnection.h"
#import "TwitterClient.h"
#import "DebugUtils.h"

@interface NSObject (SearchTableViewDelegate)
- (void)textAtIndexPath:(NSIndexPath*)indexPath;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    UIView *view = self.navigationController.navigationBar;
    searchBar = [[CustomSearchBar alloc] initWithFrame:view.bounds delegate:self];
    self.navigationController.navigationBar.topItem.titleView = searchBar;
    searchBar.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchQuery"];
    
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"searchDistance"];
    [searchBar.distanceButton setTitle:[LocationDistanceWindow stringOfDistance:index] forState:UIControlStateNormal];
    
    trendsButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trends.png"]
                                                                         style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(getTrends:)];
    self.navigationItem.rightBarButtonItem = trendsButton;
    
    reloadButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                  target:self 
                                                                  action:@selector(reload:)];
    self.navigationItem.leftBarButtonItem = reloadButton;
   
    [super viewDidLoad];
    
    trends  = [[TrendsDataSource alloc] initWithDelegate:self];
    history = [[SearchHistoryDataSource alloc] initWithDelegate:self];

    search  = [[TimelineViewDataSource alloc] initWithController:self messageType:MSG_TYPE_SEARCH_RESULT];
    
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    self.view = searchView;
    
    overlayView = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 367)];
    overlayView.searchBar  = searchBar;
    overlayView.searchView = searchView;
    [overlayView setMessage:@"" spinner:false];
    
    latitude = longitude = 0;
}


- (void)dealloc {
    [overlayView release];
    [search release];
    [trends release];
    [history release];
    [super dealloc];
}


 - (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     [self.tableView reloadData];
 }


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view.superview addSubview:overlayView];
}

 - (void)viewWillDisappear:(BOOL)animated 
{
    [overlayView removeFromSuperview];
}

 - (void)viewDidDisappear:(BOOL)animated
{
}

- (void)makeRead
{
    [self navigationController].tabBarItem.badgeValue = nil;
    for (int i = 0; i < [search.timeline countMessages]; ++i) {
        Message* m = [search.timeline messageAtIndex:i];
        m.unread = false;
    }
    unread = 0;
}

- (void)search:(NSString*)query
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    searchBar.locationButton.enabled = false;
    

    searchBar.text = query;    
    [searchBar resignFirstResponder];
    
    if ([query length] == 0) return;

    [self makeRead];

    self.navigationItem.leftBarButtonItem.enabled  = false;    
    [[NSUserDefaults standardUserDefaults] setObject:query forKey:@"searchQuery"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [search search:query];
    [overlayView setMessage:@"Searching..." spinner:true];
    
    sqlite3* database = [DBConnection getSharedDatabase];
    sqlite3_stmt *select, *insert;
    //
    // Check existing
    //
    if (sqlite3_prepare_v2(database, "SELECT query FROM queries WHERE UPPER(query) = UPPER(?)", -1, &select, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_text(select, 1, [[NSString stringWithFormat:@"%@", query] UTF8String], -1, SQLITE_TRANSIENT);    

    int result = sqlite3_step(select);
    sqlite3_finalize(select);
    if (result == SQLITE_ROW) {
        return;
    }

    // Insert query to database
    //
    if (sqlite3_prepare_v2(database, "INSERT INTO queries VALUES (?)", -1, &insert, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }

    sqlite3_bind_text(insert, 1, [query UTF8String], -1, SQLITE_TRANSIENT);
    result = sqlite3_step(insert);
    sqlite3_finalize(insert);
    
    if (result == SQLITE_ERROR) {
        NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }
}

- (void)geoSearch
{
    [overlayView setMessage:@"Searching..." spinner:true];

    int distance = [LocationDistanceWindow distanceOf:[[NSUserDefaults standardUserDefaults] integerForKey:@"searchDistance"]];
    [search geocode:latitude longitude:longitude distance:distance];
    
}

- (void)reload:(id)sender
{
    int count = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0];
    
    if (self.tableView.dataSource == trends) {
        [trends getTrends:(count != 0) ? true : false];
    }
    else if (self.tableView.dataSource == search) {
        if (count == 0) {
            if ([searchBar.text length]) {
                [self search:searchBar.text];
            }
            else {
                return;
            }
        }
        else {
            isReload = true;
            [search searchSubstance:true];
        }
    }
    else {
        return;
    }

    self.navigationItem.leftBarButtonItem.enabled = false;
}

- (void)reloadTable
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:false];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

//
// TwitterFonApPDelegate delegate
//
- (void)didLeaveTab:(UINavigationController*)navigationController
{
    [self makeRead];
}

//
// CustomSearchBar delegates
//
- (BOOL)customSearchBarShouldBeginEditing:(CustomSearchBar *)textField
{
    self.navigationItem.leftBarButtonItem.enabled = false;

    CATransition *animation = [CATransition animation];
 	[animation setDelegate:self];
    [animation setType:kCATransitionFade];
	[animation setDuration:0.25];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[[overlayView layer] addAnimation:animation forKey:@"fadeout"];
	overlayView.mode = OVERLAY_MODE_DARKEN;
    
    if (self.tableView.dataSource == search) {
        search.contentOffset = self.tableView.contentOffset;
    }
    
    [self.navigationItem setLeftBarButtonItem:nil animated:true];
    [self.navigationItem setRightBarButtonItem:nil animated:true];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    searchBar.frame = CGRectMake(0, 0, 300, 44);
    [UIView commitAnimations];
    
    return true;
}

- (BOOL)customSearchBarShouldEndEditing:(CustomSearchBar *)textField
{
    self.navigationItem.leftBarButtonItem.enabled = true;
	overlayView.mode = OVERLAY_MODE_HIDDEN;
    self.view.frame = CGRectMake(0, 0, 320, 367);
    [self.tableView reloadData];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    searchBar.frame = CGRectMake(47, 0, 220, 44);
    [UIView commitAnimations];
    
    [self.navigationItem setLeftBarButtonItem:reloadButton animated:true];
    [self.navigationItem setRightBarButtonItem:trendsButton animated:true];
    
    return true;
}

- (BOOL)customSearchBarShouldClear:(CustomSearchBar *)textField
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    [self.tableView reloadData];
    [self.tableView setContentOffset:search.contentOffset animated:false];
    overlayView.mode = OVERLAY_MODE_DARKEN;
    
    return true;
}

- (void)customSearchBar:(CustomSearchBar *)aSearchBar textDidChange:(NSString*)searchText
{
    if ([searchText length] == 0) {
        [self customSearchBarShouldClear:aSearchBar];
    }
    else {
        self.view.frame = CGRectMake(0, 0, 320, 200);
        [history updateQuery:searchText];
        overlayView.mode = OVERLAY_MODE_SHADOW;
        self.tableView.dataSource = history;
        self.tableView.delegate   = history;
        [self reloadTable];
    }
}

- (void)customSearchBarDistanceButtonClicked:(CustomSearchBar*)aSearchBar
{
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"searchDistance"];
    LocationDistanceWindow *window = [[LocationDistanceWindow alloc] initWithDelegate:self selectedRow:index];
    [window show];
}

- (void)locationDistanceWindow:(LocationDistanceWindow*)window didChangeDistance:(int)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"searchDistance"];
    [[NSUserDefaults standardUserDefaults] synchronize];   
    [searchBar.distanceButton setTitle:[LocationDistanceWindow stringOfDistance:index] forState:UIControlStateNormal];
    
    if (latitude && longitude) {
        [self geoSearch];
    }
}

- (void)customSearchBarBookmarkButtonClicked:(CustomSearchBar*)aSearchBar
{
    SearchHistoryViewController *bookmarks = [[[SearchHistoryViewController alloc] initWithNibName:@"SearchHistoryView" bundle:nil] autorelease];

    bookmarks.searchView = self;
    [self.navigationController presentModalViewController:bookmarks animated:true];
}

- (void)customSearchBarLocationButtonClicked:(CustomSearchBar*)aSearchBar
{
    [self makeRead];
    self.navigationItem.leftBarButtonItem.enabled = false;
    aSearchBar.locationButton.enabled = false;

    [search removeAllMessages];
    [self reloadTable];
    
    [searchBar resignFirstResponder];
    [overlayView setMessage:@"Get current location..." spinner:true];
    
    LocationManager *location = [[LocationManager alloc] initWithDelegate:self];
    [location getCurrentLocation];
}

- (void)customSearchBarSearchButtonClicked:(CustomSearchBar *)aSearchBar
{
    [self search:aSearchBar.text];
}

//
// SearchDataSource delegates
//

- (void)searchDidLoad:(int)count insertAt:(int)position
{
    [searchBar resignFirstResponder];
    overlayView.mode = OVERLAY_MODE_HIDDEN;
    self.navigationItem.leftBarButtonItem.enabled = true;    
    searchBar.locationButton.enabled = true;
    
    if (self.tableView.dataSource != search) {
        self.tableView.dataSource = search;
        self.tableView.delegate   = search;
    }
    
    if (count == 0) return;
    
    if (isReload && count) {
        unread += count;
        [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];
    }
    

    if (self.navigationController.tabBarController.selectedIndex == TAB_SEARCH &&
        self.navigationController.topViewController == self) {

        if (isReload) {
            if (count > 8) count = 8;
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 0; i < count; ++i) {
                [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        else if (count && position) {
            NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:position inSection:0]];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        else {
            [self reloadTable];
        }
    }
    else {
        [self reloadTable];
    }
    isReload = false;
}


- (void)noSearchResult
{
    if (!isReload) {
        [overlayView setMessage:@"No search result." spinner:false];
    }
    isReload = false;
    self.navigationItem.leftBarButtonItem.enabled = true;
    searchBar.locationButton.enabled = true;
}

- (void)timelineDidFailToUpdate:(TimelineViewDataSource*)sender position:(int)position
{
    isReload = false;
    if (position == 0) {
        [overlayView setMessage:@"Search is not available." spinner:false];
    }
    self.navigationItem.leftBarButtonItem.enabled = true;
    searchBar.locationButton.enabled = true;
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

//
// LocationManager delegate
//
- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)location
{
    latitude  = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    [self geoSearch];
    [manager autorelease];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    [overlayView setMessage:@"Can't get current location." spinner:false];
    self.navigationItem.leftBarButtonItem.enabled = true;
    searchBar.locationButton.enabled = true;
    [manager autorelease];
}

//
// Trends
//
- (void)getTrends:(id)sender
{
    [self makeRead];
    self.navigationItem.leftBarButtonItem.enabled  = false;
    self.navigationItem.rightBarButtonItem.enabled = false;
    [searchBar resignFirstResponder];
    [overlayView setMessage:@"Get trends..." spinner:true];
    [trends getTrends:false];
}

- (void)searchTrendsDidLoad
{
    [searchBar resignFirstResponder];
    overlayView.mode = OVERLAY_MODE_HIDDEN;

    self.tableView.delegate   = trends;
    self.tableView.dataSource = trends;
    self.navigationItem.leftBarButtonItem.enabled  = true;
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self reloadTable];
}

- (void)searchTrendsDidFailToLoad
{
    [overlayView setMessage:@"Failed to get trends." spinner:false];
    self.navigationItem.leftBarButtonItem.enabled  = true;
    self.navigationItem.rightBarButtonItem.enabled = true;
}

- (void)didReceiveMemoryWarning
{
    // Do not release this view controller
    //[super didReceiveMemoryWarning];
}

@end

