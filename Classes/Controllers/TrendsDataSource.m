//
//  TrendsDataSource.m
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TrendsDataSource.h"
#import "TwitterClient.h"

@interface NSObject (TrendsDataSourceDelegate)
- (void)searchTrendsDidLoad;
- (void)searchTrendsDidFailToLoad;
- (void)search:(NSString*)query;
@end

@implementation TrendsDataSource

- (id)initWithDelegate:(id)aDelegate
{
    [super init];
    trends = [[NSMutableArray alloc] init];
    delegate = aDelegate;
    return self;
}

- (void)dealloc
{ 
    [trends release];
    [super dealloc];
}


- (void)getTrends:(BOOL)reload
{
    if (reload || [trends count] == 0) {
        TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(trendDidReceive:messages:)];
        [client trends];
    }
    else {
        [delegate searchTrendsDidLoad];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    tableView.separatorColor = [UIColor colorWithRed:0.878 green:0.878 blue:0.878 alpha:1.0];
    tableView.backgroundColor = [UIColor whiteColor];

    return [trends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SearchCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.text = [trends objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [delegate search:[trends objectAtIndex:indexPath.row]];
}

//
// TwitterClient delegates
//
- (void)trendDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;
        
        NSArray *array = (NSArray*)[dic objectForKey:@"trends"];
        
        [trends removeAllObjects];
        for (int i = 0; i < [array count]; ++i) {
            NSDictionary *trend = (NSDictionary*)[array objectAtIndex:i];
            [trends addObject:(NSString*)[trend objectForKey:@"name"]];
        }            
    }
    [delegate searchTrendsDidLoad];
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
    
    [delegate searchTrendsDidFailToLoad];
}


@end
