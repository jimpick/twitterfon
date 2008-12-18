//
//  SearchResultsDataSource.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TwitterFonAppDelegate.h"
#import "SearchResultsDataSource.h"
#import "TweetViewController.h"
#import "TimelineCell.h"
#import "StringUtil.h"

@interface NSObject (SearchResultsDataSourceDelegate)
- (void)timelineDidUpdate:(SearchResultsDataSource*)sender count:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate:(SearchResultsDataSource*)sender position:(int)position;
- (void)searchDidLoad:(int)count insertAt:(int)insertAt;
- (void)noSearchResult;
@end

@implementation SearchResultsDataSource

- (id)initWithController:(UITableViewController*)aController
{
    [super init];
    
    controller  = aController;
    [loadCell setType:MSG_TYPE_LOAD_FROM_WEB];

    return self;
}

- (void)dealloc {
    [nextPageUrl release];
    [refreshUrl release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [timeline countStatuses];
    return (count) ? count + 1 : 0;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status* sts = [timeline statusAtIndex:indexPath.row];
    return sts ? sts.cellHeight : 78;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineCell* cell = [timeline getTimelineCell:tableView atIndex:indexPath.row];
    if (cell) {
        return cell;
    }
    else {
        return loadCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status* sts = [timeline statusAtIndex:indexPath.row];
    
    if (sts) {
        // Display user timeline
        //
        TweetViewController* tweetView = [[[TweetViewController alloc] initWithMessage:sts] autorelease];
        [[controller navigationController] pushViewController:tweetView animated:TRUE];
    }      
    else {
        [loadCell.spinner startAnimating];
        [self nextPage];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

- (void)searchByQuery:(NSString*)query
{
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(searchResultDidReceive:obj:)];
    [twitterClient search:query];
}

- (void)reset
{
    isReloading = false;
    isPaging = false;
    [refreshUrl release];
    [nextPageUrl release];
    refreshUrl = nil;
    nextPageUrl = nil;
    insertPosition = 0;
    [timeline removeAllStatuses];
}

- (void)search:(NSString*)query
{
    if (twitterClient) return;
    
    [self reset];
    NSString *q = [NSString stringWithFormat:@"?q=%@", [query encodeAsURIComponent]];
    [self searchByQuery:q];
}

- (void)reload
{
    if (twitterClient) return;

    isReloading = true;
    isPaging = false;
    insertPosition = 0;
    if (refreshUrl) {
        [self searchByQuery:refreshUrl];
    }
}

- (void)nextPage
{
    if (twitterClient) return;

    isReloading = false;
    isPaging = true;
    insertPosition = [timeline countStatuses];
    if (nextPageUrl) {
        [self searchByQuery:nextPageUrl];
    }
}

- (void)geocode:(float)latitude longitude:(float)longitude distance:(int)distance
{
    [self reset];

    BOOL useMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    [geocode release];
    geocode = [NSString stringWithFormat:@"?geocode=%f,%f,%d%@", latitude, longitude, distance, (useMetric) ? @"km" : @"mi"];
    [geocode retain];

    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(geoSearchResultDidReceive:obj:)];
    [twitterClient search:geocode];
    
}

- (int)countResults
{
    return [timeline countStatuses];
}

- (NSDictionary*)searchResultDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    twitterClient = nil;
    if (![obj isKindOfClass:[NSDictionary class]]) {
        [controller noSearchResult];
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary*)obj;
        
    NSArray *array = (NSArray*)[dic objectForKey:@"results"];

    if ([array count] == 0) {
        [controller noSearchResult];
        return nil;
    }
    
    [loadCell.spinner stopAnimating];
    
    // Add messages to the timeline
    //
    for (int i = [array count] - 1; i >= 0; --i) {
        Status* sts = [Status statusWithSearchResult:[array objectAtIndex:i]];
        if ([timeline indexOfObject:sts] == -1) {
            [timeline insertStatus:sts atIndex:insertPosition];
            if (isReloading) {
                sts.unread = true;
            }
        }
    }

    if ([controller respondsToSelector:@selector(searchDidLoad:insertAt:)]) {
        [controller searchDidLoad:[array count] insertAt:insertPosition];
    }

    //
    // Setup for next search
    //
    if (isReloading || refreshUrl == nil) {
        refreshUrl = [dic objectForKey:@"refresh_url"];
        if ((id)refreshUrl == [NSNull null]) {
            refreshUrl = nil;
        }
        else {
            [refreshUrl retain];
        }
    }
    
    if (isPaging || nextPageUrl == nil) {
        nextPageUrl   = [dic objectForKey:@"next_page"];
        if ((id)nextPageUrl == [NSNull null]) {
            nextPageUrl = nil;
        }
        else {
            [nextPageUrl retain];
        }
    }
    return dic;
}

- (void)geoSearchResultDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    NSDictionary *dic = [self searchResultDidReceive:sender obj:obj];
    if (dic && refreshUrl) {
        NSString *tmp = [refreshUrl stringByAppendingFormat:@"&%@", [geocode substringFromIndex:1]];
        [refreshUrl release];
        refreshUrl = [tmp retain];
        NSLog(@"%@", refreshUrl);
    }
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    twitterClient = nil;
    [loadCell.spinner stopAnimating];
    
    if ([controller respondsToSelector:@selector(timelineDidFailToUpdate:position:)]) {
        [controller timelineDidFailToUpdate:self position:insertPosition];
    }
    [[TwitterFonAppDelegate getAppDelegate] alert:error message:detail];
}

@end
