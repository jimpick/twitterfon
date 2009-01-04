//
//  SearchBookmarksViewController.m
//  TwitterFon
//
//  Created by kaz on 10/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "SearchHistoryViewController.h"
#import "DBConnection.h"

@interface NSObject (TrendsDataSourceDelegate)
- (void)search:(NSString*)query;
@end

@implementation SearchHistoryViewController

@synthesize searchView;

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [toolbar setItems:[NSArray arrayWithObject:[self editButtonItem]] animated:false];
//    self.navigationItem.leftBarButtonItem = [self editButtonItem];
    self.editing = NO;
    
    queries = [[NSMutableArray alloc] init];

    Statement *stmt = [DBConnection statementWithQuery:"SELECT query FROM queries ORDER BY UPPER(query)"];
    while ([stmt step] == SQLITE_ROW) {
        [queries addObject:[stmt getString:0]];
    }
}

- (void)dealloc {
    [queries release];
    [super dealloc];
}


/*
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 }
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [queries count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SearchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.text = [queries objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [[self parentViewController] dismissModalViewControllerAnimated:true];
    [searchView search:[queries objectAtIndex:indexPath.row]];
}

- (IBAction)close:(id)sender
{
    [[self parentViewController] dismissModalViewControllerAnimated:true];
}

- (void)clearAllCache:(id)sender
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Clear All Histories"
                                           otherButtonTitles:nil];
    [as showInView:self.view];
    [as release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        Statement *stmt = [DBConnection statementWithQuery:"DELETE FROM queries"];
        if ([stmt step] != SQLITE_DONE) {
            [DBConnection alert];
        }
        [queries removeAllObjects];
        [bookmarkView reloadData];
        self.editing = false;
        
        [[self parentViewController] dismissModalViewControllerAnimated:true];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [bookmarkView setEditing:editing animated:animated];
    if (editing) {
        NSArray *array = [NSArray arrayWithObjects:[self editButtonItem],
                          [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                          [[[UIBarButtonItem alloc] initWithTitle:@"Clear all cache" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAllCache:)] autorelease],
                          nil];
                           
        [toolbar setItems:array animated:true];
        [self.navigationItem setRightBarButtonItem:nil animated:true];
    }
    else {
        [toolbar setItems:[NSArray arrayWithObject:[self editButtonItem]] animated:true];
        [self.navigationItem setRightBarButtonItem:closeButton animated:true];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Statement *stmt = [DBConnection statementWithQuery:"DELETE FROM queries WHERE query = ?"];

        NSString *query = [queries objectAtIndex:indexPath.row];
        [stmt bindString:query forIndex:1];

        if ([stmt step] != SQLITE_DONE) {
            [DBConnection alert];
        }   
        [queries removeObject:query];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


@end

