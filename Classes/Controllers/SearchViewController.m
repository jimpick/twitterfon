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
#import "DBConnection.h"
#import "TwitterClient.h"
#import "LoadCell.h"

@interface NSObject (SearchTableViewDelegate)
- (void)textAtIndexPath:(NSIndexPath*)indexPath;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    UIView *view = self.navigationController.navigationBar;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height)];
    self.navigationController.navigationBar.topItem.titleView = searchBar;
    searchBar.delegate = self;
    searchBar.showsBookmarkButton = true;

    UIBarButtonItem *trendButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trends.png"]
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(getTrends:)];
    self.navigationItem.rightBarButtonItem = trendButton;
    
    UIBarButtonItem *locationButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self 
                                                                       action:@selector(getLocation:)];
    self.navigationItem.leftBarButtonItem = locationButton;
   
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
     self.tableView.scrollsToTop = true; 
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

- (void)search:(NSString*)query
{
    
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;

    searchBar.text = query;    
    [searchBar resignFirstResponder];
    [search search:query];
    [overlayView setMessage:@"Loading..." spinner:true];
    
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

- (void)reloadTable
{
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:false];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

//
// UISearchBar delegates
//
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    CATransition *animation = [CATransition animation];
 	[animation setDelegate:self];
    [animation setType:kCATransitionFade];
	[animation setDuration:0.3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	overlayView.mode = OVERLAY_MODE_DARKEN;
	[[self.view.superview layer] addAnimation:animation forKey:@"fadeout"];
    
    if (self.tableView.dataSource == search) {
        search.contentOffset = self.tableView.contentOffset;
    }
    self.view.frame = CGRectMake(0, 0, 320, 200);
    
    return true;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	overlayView.mode = OVERLAY_MODE_HIDDEN;
    self.view.frame = CGRectMake(0, 0, 320, 367);
    [self.tableView reloadData];
    return true;
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] == 0) {
        self.tableView.dataSource = search;
        self.tableView.delegate   = search;
        [self.tableView reloadData];
        [self.tableView setContentOffset:search.contentOffset animated:false];
        overlayView.mode = OVERLAY_MODE_DARKEN;
        return;
    }
    
    [history updateQuery:searchText];
    overlayView.mode = OVERLAY_MODE_SHADOW;
    self.tableView.dataSource = history;
    self.tableView.delegate   = history;
    [self reloadTable];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    SearchHistoryViewController *bookmarks = [[[SearchHistoryViewController alloc] initWithNibName:@"SearchHistoryView" bundle:nil] autorelease];

    bookmarks.searchView = self;
    [self.navigationController presentModalViewController:bookmarks animated:true];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self search:aSearchBar.text];
}

//
// SearchDataSource delegates
//

- (void)searchDidLoad:(int)count insertAt:(int)position
{
    overlayView.mode = OVERLAY_MODE_HIDDEN;

    if (self.tableView.dataSource != search) {
        self.tableView.dataSource = search;
        self.tableView.delegate   = search;
    }
    if (!self.view.hidden && position && count) {
        [self.tableView beginUpdates];
        NSMutableArray *insertion = [[[NSMutableArray alloc] init] autorelease];
        [insertion addObject:[NSIndexPath indexPathForRow:position inSection:0]];
        [self.tableView insertRowsAtIndexPaths:insertion withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    else {
        [self reloadTable];
    }
    self.navigationItem.leftBarButtonItem.enabled = true;    
}


- (void)noSearchResult
{
    [overlayView setMessage:@"No search result." spinner:false];
}

- (void)timelineDidFailToUpdate:(TimelineViewDataSource*)sender position:(int)position
{
    if (position == 0) {
        [overlayView setMessage:@"Search is not available." spinner:false];
    }
    else {
        LoadCell *cell = (LoadCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:0]];
        if ([cell isKindOfClass:[LoadCell class]]) {
            [cell.spinner stopAnimating];
        }
    }
    self.navigationItem.leftBarButtonItem.enabled = true;
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

- (void)getLocation:(id)sender
{
    [search removeAllMessages];
    [self reloadTable];

    self.navigationItem.leftBarButtonItem.enabled = false;
    
    [searchBar resignFirstResponder];
    [overlayView setMessage:@"Loading..." spinner:true];
    
    LocationManager *location = [[LocationManager alloc] initWithDelegate:self];
    [location getCurrentLocation];
}

- (void)locationManagerDidReceiveLocation:(LocationManager*)manager location:(CLLocation*)location
{
    searchBar.text = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    [search geocode:location.coordinate.latitude longitude:location.coordinate.longitude];
    [manager autorelease];
}

- (void)locationManagerDidFail:(LocationManager*)manager
{
    [overlayView setMessage:@"Can't get current location." spinner:false];
    self.navigationItem.leftBarButtonItem.enabled = true;
    [manager autorelease];
}

- (void)getTrends:(id)sender
{
    self.navigationItem.rightBarButtonItem.enabled = false;
    [searchBar resignFirstResponder];
    [overlayView setMessage:@"Loading..." spinner:true];
    [trends getTrends];
}

- (void)searchTrendsDidLoad
{
    overlayView.mode = OVERLAY_MODE_HIDDEN;
    self.tableView.delegate   = trends;
    self.tableView.dataSource = trends;
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self reloadTable];
}

- (void)searchTrendsDidFailToLoad
{
    [overlayView setMessage:@"Failed to get trends." spinner:false];
    self.navigationItem.rightBarButtonItem.enabled = true;
}

- (void)didReceiveMemoryWarning
{
    // Do not release this view controller
    //[super didReceiveMemoryWarning];
}

@end

