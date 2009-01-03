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

@interface SearchViewController (Private)
- (void)setDataSource:(NSObject<UITableViewDelegate, UITableViewDataSource>*)source;
@end


@implementation SearchViewController

- (void)viewDidLoad 
{
    // SearchBar
    //
    UIView *view = self.navigationController.navigationBar;
    searchBar = [[[CustomSearchBar alloc] initWithFrame:view.bounds delegate:self] autorelease];
    searchBar.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"searchQuery"];
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:@"searchDistance"];
    [searchBar.distanceButton setTitle:[LocationDistanceWindow stringOfDistance:index] forState:UIControlStateNormal];
    self.navigationController.navigationBar.topItem.titleView = searchBar;

    // Trends
    trendsButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trends.png"]
                                                                         style:UIBarButtonItemStylePlain 
                                                                         target:self 
                                                                         action:@selector(getTrends:)];
    self.navigationItem.rightBarButtonItem = trendsButton;
    
    // Reload
    reloadButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                  target:self 
                                                                  action:@selector(reload:)];
    self.navigationItem.leftBarButtonItem = reloadButton;

    // Data sources and delegates
    //
    trends  = [[TrendsDataSource alloc] initWithDelegate:self];
    history = [[SearchHistoryDataSource alloc] initWithDelegate:self];
    search  = [[SearchResultsDataSource alloc] initWithController:self];
    [self setDataSource:search];
    
    // Overlay view
    overlayView = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 367)];
    overlayView.searchBar  = searchBar;
    overlayView.searchView = searchView;
    [overlayView setMessage:@"" spinner:false];

    // etc
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

- (void)setDataSource:(NSObject<UITableViewDelegate, UITableViewDataSource>*)source
{
    if (source == search) {
        self.tableView.separatorColor   = [UIColor lightGrayColor]; 
        self.tableView.backgroundColor  = [UIColor whiteColor];
    }
    else if (source == trends) {
        self.tableView.separatorColor   = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.0];
        self.tableView.backgroundColor  = [UIColor whiteColor];
    }
    else if (source == history) {
        self.tableView.separatorColor  = [UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.0];
    }
    self.tableView.dataSource = source;
    self.tableView.delegate   = source;
    [self.tableView setNeedsDisplay];
}

- (void)makeRead
{
    [self navigationController].tabBarItem.badgeValue = nil;
    for (int i = 0; i < [search.timeline countStatuses]; ++i) {
        Status* sts = [search.timeline statusAtIndex:i];
        sts.unread = false;
    }
    unread = 0;
}

- (void)search:(NSString*)query
{
    [self setDataSource:search];
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
    
    //
    // Insert query to query history
    //
    Statement *stmt = [DBConnection statementWithQuery:"REPLACE INTO queries VALUES (?)"];
    [stmt bindString:query forIndex:1];
    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection alert];
    }
}

- (void)geoSearch
{
    [self makeRead];
    [overlayView setMessage:@"Searching..." spinner:true];

    int distance = [LocationDistanceWindow distanceOf:[[NSUserDefaults standardUserDefaults] integerForKey:@"searchDistance"]];
    [search geocode:latitude longitude:longitude distance:distance];
    
}

- (void)reload:(id)sender
{
    int count = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0];
    
    [searchBar resignFirstResponder];
    
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
            [search reload];
        }
    }
    else {
        return;
    }

    self.navigationItem.leftBarButtonItem.enabled = false;
}

- (void)autoRefresh
{
    if (self.tableView.dataSource == search && [search countResults]) {
        [self reload:nil];
    }
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
    CATransition *animation = [CATransition animation];
 	[animation setDelegate:nil];
    [animation setType:kCATransitionFade];
	[animation setDuration:0.4];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[overlayView layer] addAnimation:animation forKey:@"fadeout"];
	overlayView.mode = OVERLAY_MODE_DARKEN;
    
    if (self.tableView.dataSource == search) {
        search.contentOffset = self.tableView.contentOffset;
    }
    searchBar.locationButton.enabled = false;
    self.navigationItem.leftBarButtonItem.enabled = false;
    
    return true;
}

- (BOOL)customSearchBarShouldEndEditing:(CustomSearchBar *)textField
{
    self.view.frame = CGRectMake(0, 0, 320, 367);
    searchBar.locationButton.enabled = true;
    self.navigationItem.leftBarButtonItem.enabled = true;
    return true;
}

- (BOOL)customSearchBarShouldClear:(CustomSearchBar *)textField
{
    [self setDataSource:search];
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
        [self setDataSource:history];
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
        [search cancel];
        [search removeAllStatuses];
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
        [self setDataSource:search];
    }
    
    if (count == 0) return;
    
    if (isReload && count) {
        unread += count;
        [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];
    }

    if (self.navigationController.tabBarController.selectedIndex == TAB_SEARCH &&
        self.navigationController.topViewController == self) {

        NSMutableArray *array = [NSMutableArray array];
        if (isReload) {
            if (count > 8) count = 8;
            for (int i = 0; i < count; ++i) {
                [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        else if (count && position) {
            if (count > 2) count = 2;
            for (int i = 0; i < count; ++i) {
                [array addObject:[NSIndexPath indexPathForRow:position + i inSection:0]];
            }
        }
        else {
            [self reloadTable];
        }
        if ([array count]) {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
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

- (void)timelineDidFailToUpdate:(SearchResultsDataSource*)sender position:(int)position
{
    isReload = false;
    if (position == 0) {
        [overlayView setMessage:@"Search is not available." spinner:false];
    }
    self.navigationItem.leftBarButtonItem.enabled = true;
    searchBar.locationButton.enabled = true;
}

//
// LocationManager delegate
//
- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)location
{
    [search removeAllStatuses];
    [self reloadTable];
    
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

    [self setDataSource:trends];
    [self reloadTable];
    self.navigationItem.leftBarButtonItem.enabled  = true;
    self.navigationItem.rightBarButtonItem.enabled = true;
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

