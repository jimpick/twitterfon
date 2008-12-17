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

- (int)updateQuery:(NSString*)query
{
    [queries removeAllObjects];
    
    if ([query length] == 0) return 0;
    
    if (select_statement == nil) {
        select_statement = [DBConnection prepate:"SELECT query FROM queries WHERE query LIKE ? ORDER BY UPPER(query)"];
    }
    
    sqlite3_bind_text(select_statement, 1, [[NSString stringWithFormat:@"%%%@%%", query] UTF8String], -1, SQLITE_TRANSIENT);    

    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        [queries addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 0)]];
    }
    sqlite3_reset(select_statement);
    return [queries count];
}

- (void)removeAllQueries
{
    [queries removeAllObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
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
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [delegate search:[queries objectAtIndex:indexPath.row]];

}

@end
