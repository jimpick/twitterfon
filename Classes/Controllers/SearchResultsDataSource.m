//
//  SearchResultsDataSource.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SearchResultsDataSource.h"
#import "UserViewController.h"
#import "TimelineMessageCell.h"
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
    int count = [timeline countMessages];
    return (count) ? count + 1 : 0;
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m ? m.cellHeight : 78;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimelineMessageCell* cell = [timeline getMessageCell:tableView atIndex:indexPath.row];
    if (cell) {
        return cell;
    }
    else {
        return loadCell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    
    if (m) {
        // Display user timeline
        //
        UserViewController* userView = [[[UserViewController alloc] initWithMessage:m] autorelease];
        [[controller navigationController] pushViewController:userView animated:TRUE];
    }      
    else {
        [loadCell.spinner startAnimating];
        [self nextPage];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

- (void)searchByQuery:(NSString*)query
{
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(searchResultDidReceive:messages:)];
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
    [timeline removeAllMessages];
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
    insertPosition = [timeline countMessages];
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

    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(geoSearchResultDidReceive:messages:)];
    [twitterClient search:geocode];
    
}

- (int)countResults
{
    return [timeline countMessages];
}

- (NSDictionary*)searchResultDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
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
        Message* m = [Message messageWithSearchResult:[array objectAtIndex:i]];
        if ([timeline indexOfObject:m] == -1) {
            [timeline insertMessage:m atIndex:insertPosition];
            if (isReloading) {
                m.unread = true;
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

- (void)geoSearchResultDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    NSDictionary *dic = [self searchResultDidReceive:sender messages:obj];
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

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
}

@end
