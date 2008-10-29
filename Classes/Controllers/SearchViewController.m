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
#import "SearchBookmarksViewController.h"
#import "DBConnection.h"
#import "SearchView.h"
#import "TwitterClient.h"

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
    SearchView* searchView = (SearchView*)self.view;
    searchView.searchBar = searchBar;

//    UIBarButtonItem *trendButton  = [[UIBarButtonItem alloc] initWithTitle:@"Trends"
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
    search  = [[SearchResultDataSource alloc] initWithDelegate:self];
    history = [[SearchHistoryDataSource alloc] initWithDelegate:self];

    self.tableView.dataSource = search;
    self.tableView.delegate   = search;

    location = [[LocationManager alloc] initWithDelegate:self];
    
    needToOpenKeyboard = true;
}


- (void)dealloc {
    [location release];
    [search release];
    [trends release];
    [history release];
    [super dealloc];
}

/*
 - (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
 }
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (needToOpenKeyboard) {
        [searchBar becomeFirstResponder];
        needToOpenKeyboard = false;
    }
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 }
 */

- (void)didLeaveTab:(UINavigationController*)navigationController
{
    needToOpenKeyboard = true;
}

- (void)search:(NSString*)query
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;

    searchBar.text = query;    
    [searchBar resignFirstResponder];
    [search search:query];
    
    sqlite3* database = [DBConnection getSharedDatabase];
    sqlite3_stmt *select, *insert;
    //
    // Check existing
    //
    if (sqlite3_prepare_v2(database, "SELECT query FROM queries WHERE UPPER(query) = UPPER(?)", -1, &select, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare delete statement with message '%s'.", sqlite3_errmsg(database));
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
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
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
- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchText
{
    self.tableView.dataSource = history;
    self.tableView.delegate   = history;
    
    [history updateQuery:searchText];
    [self reloadTable];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    SearchBookmarksViewController *bookmarks = [[[SearchBookmarksViewController alloc] initWithNibName:@"BookmarkView" bundle:nil] autorelease];

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

- (void)searchDidLoad
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    [self reloadTable];
    self.navigationItem.leftBarButtonItem.enabled = true;    
}


- (void)noSearchResult
{
}

- (void)searchDidFailToLoad
{
    self.navigationItem.leftBarButtonItem.enabled = true;
}

- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

- (void)getLocation:(id)sender
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    [search removeAllResults];
    [self reloadTable];

    self.navigationItem.leftBarButtonItem.enabled = false;
    
    [searchBar resignFirstResponder];
    [location getCurrentLocation];
}

- (void)locationManagerDidReceiveLocation:(float)latitude longitude:(float)longitude
{
    self.tableView.dataSource = search;
    self.tableView.delegate   = search;
    
    searchBar.text = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
    [search geocode:latitude longitude:longitude];
    
}

- (void)locationManagerDidFail
{
    self.navigationItem.leftBarButtonItem.enabled = true;
}

- (void)getTrends:(id)sender
{
    self.tableView.delegate   = trends;
    self.tableView.dataSource = trends;
    
    self.navigationItem.rightBarButtonItem.enabled = false;
    [searchBar resignFirstResponder];
    [trends getTrends];
}

//
// TrendsDataSource delegates
//
- (void)searchTrendsDidLoad
{
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self reloadTable];
}

- (void)searchTrendsDidFailToLoad
{
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self reloadTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

