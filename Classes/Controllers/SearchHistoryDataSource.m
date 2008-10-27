//
//  SearchHistoryDataSource.m
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DBConnection.h"
#import "SearchHistoryDataSource.h"

static sqlite3_stmt *select_statement = nil;

@interface NSObject (TrendsDataSourceDelegate)
- (void)search:(NSString*)query;
@end

@implementation SearchHistoryDataSource

- (id)initWithDelegate:(id)aDelegate
{
    [super init];
    delegate = aDelegate;
    queries  = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc
{
    [queries release];
    [super dealloc];
}

- (void)updateQuery:(NSString*)query
{
    [queries removeAllObjects];
    
    if ([query compare:@""] == NSOrderedSame) return;
    
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (select_statement == nil) {
        static char *sql = "SELECT query FROM queries WHERE query like ? ORDER BY UPPER(query)";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_text(select_statement, 1, [[NSString stringWithFormat:@"%%%@%%", query] UTF8String], -1, SQLITE_TRANSIENT);    


    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        [queries addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 0)]];
    }
    sqlite3_reset(select_statement);
}

- (void)removeAllQueries
{
    [queries removeAllObjects];
}

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
    cell.text = [queries objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [delegate search:[queries objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

@end
