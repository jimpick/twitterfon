//
//  SearchBookmarksViewController.m
//  TwitterFon
//
//  Created by kaz on 10/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "FriendsViewController.h"
#import "PostViewController.h"
#import "DBConnection.h"
#import "FriendCell.h"
#import "User.h"

@implementation FriendsViewController

@synthesize postViewController;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    letters = [[NSMutableArray alloc] init];
    index = [[NSMutableArray alloc] init];
    numLetters = 0;
    sqlite3* database = [DBConnection getSharedDatabase];
    
    sqlite3_stmt* statement;
    if (sqlite3_prepare_v2(database, "SELECT * FROM users ORDER BY UPPER(screen_name)", -1, &statement, NULL) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to prepare delete statement with message '%s'.", sqlite3_errmsg(database));
    }

    NSString *prevLetter = nil;
    NSMutableArray *array = nil;
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        User *user = [[User initWithDB:statement] autorelease];
        NSString *letter = [[user.screenName substringToIndex:1] uppercaseString];
        if ([letter compare:prevLetter] != NSOrderedSame) {
            [letters addObject:letter];
            if (array) {
                [index addObject:array];
            }
            prevLetter = letter;
            ++numLetters;
            array = [NSMutableArray arrayWithObject:user];
        }
        else {
            [array addObject:user];
        }
            
//        [friends addObject:user];
    }
    if (array) {
        [index addObject:array];
    }
    
    sqlite3_finalize(statement);
}

- (void)dealloc {
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
    return numLetters;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[index objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    User *user = [[index objectAtIndex:section] objectAtIndex:0];
    return [[user.screenName substringToIndex:1] uppercaseString];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return letters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	// Return the index for the given section title
	return [letters indexOfObject:title];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FriendCell";
    
    FriendCell *cell = (FriendCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[FriendCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    User *u = [[index objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.user = u;
    [cell updateAttribute];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [[self parentViewController] dismissModalViewControllerAnimated:true];
    User *user = [[index objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [postViewController friendsViewDidSelectFriend:user.screenName];
}

- (IBAction)close:(id)sender
{
    [[self parentViewController] dismissModalViewControllerAnimated:true];
    [postViewController friendsViewDidSelectFriend:nil];
}

@end

