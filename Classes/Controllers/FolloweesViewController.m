//
//  SearchBookmarksViewController.m
//  TwitterFon
//
//  Created by kaz on 10/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "FolloweesViewController.h"
#import "PostViewController.h"
#import "DBConnection.h"
#import "FolloweeCell.h"
#import "User.h"

@implementation FolloweesViewController

@synthesize postViewController;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    letters = [[NSMutableArray alloc] init];
    index = [[NSMutableArray alloc] init];
    searchResult = [[NSMutableArray alloc] init];
    numLetters = 0;
    inSearch = false;
    sqlite3* database = [DBConnection getSharedDatabase];
    
    sqlite3_stmt* statement;
    if (sqlite3_prepare_v2(database, "SELECT * FROM followees ORDER BY UPPER(screen_name)", -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
    }

    NSString *prevLetter = nil;
    NSMutableArray *array = nil;
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        Followee *followee = [[Followee initWithDB:statement] autorelease];
        NSString *letter = [[followee.screenName substringToIndex:1] uppercaseString];
        if ([letter isEqualToString:prevLetter] == false) {
            [letters addObject:letter];
            if (array) {
                [index addObject:array];
            }
            prevLetter = letter;
            ++numLetters;
            array = [NSMutableArray arrayWithObject:followee];
        }
        else {
            [array addObject:followee];
        }
    }
    if (array) {
        [index addObject:array];
    }
    sqlite3_finalize(statement);
}

- (void)dealloc {
    [searchResult release];
    [index release];
    [letters release];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [postViewController friendsViewDidDisappear];
}

/*
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return inSearch ? 1 : numLetters;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return inSearch ? [searchResult count] : [[index objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (inSearch) {
        return @"";
    }
    else {
        Followee *followee = [[index objectAtIndex:section] objectAtIndex:0];
        return [[followee.screenName substringToIndex:1] uppercaseString];
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return inSearch ? nil : letters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title
    return inSearch ? 0 : [letters indexOfObject:title];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FolloweeCell";
    
    FolloweeCell *cell = (FolloweeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FolloweeCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    Followee *followee;
    if (inSearch) {
        followee = [searchResult objectAtIndex:indexPath.row];
    }
    else {
        followee = [[index objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    cell.followee = followee;
    [cell updateAttribute];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [[self parentViewController] dismissModalViewControllerAnimated:true];
    Followee *followee;
    if (inSearch) {
         followee = [searchResult objectAtIndex:indexPath.row];
    }
    else {
        followee = [[index objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    [postViewController friendsViewDidSelectFriend:followee.screenName];
}

- (IBAction)close:(id)sender
{
    [[self parentViewController] dismissModalViewControllerAnimated:true];
    [postViewController friendsViewDidSelectFriend:nil];
}

//
// UISearchBar delegates
//
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    friendsView.frame = CGRectMake(0, 44, 320, 200);
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    friendsView.frame = CGRectMake(0, 44, 320, 436);
}

static sqlite3_stmt *search_statement = nil;

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)query
{
    [searchResult removeAllObjects];
    if ([query length] == 0) {
        inSearch = false;
    }
    else {
        inSearch = true;
        sqlite3* database = [DBConnection getSharedDatabase];
        if (search_statement == nil) {
            if (sqlite3_prepare_v2(database, "SELECT * FROM followees WHERE name LIKE ? OR screen_name LIKE ? ORDER BY UPPER(screen_name)", -1, &search_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        
        sqlite3_bind_text(search_statement, 1, [[NSString stringWithFormat:@"%%%@%%", query] UTF8String], -1, SQLITE_TRANSIENT);    
        sqlite3_bind_text(search_statement, 2, [[NSString stringWithFormat:@"%%%@%%", query] UTF8String], -1, SQLITE_TRANSIENT);    
        
        while (sqlite3_step(search_statement) == SQLITE_ROW) {
            Followee *followee = [[Followee initWithDB:search_statement] autorelease];
            [searchResult addObject:followee];
        }
        sqlite3_reset(search_statement);
    }
    [friendsView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [aSearchBar resignFirstResponder];
}
@end

