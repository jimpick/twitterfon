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

@interface NSObject (SearchResultsDataSourceDelegate)
- (void)timelineDidUpdate:(SearchResultsDataSource*)sender count:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate:(SearchResultsDataSource*)sender position:(int)position;
- (void)searchDidLoad:(int)count insertAt:(int)insertAt;
- (void)noSearchResult;
@end

@implementation SearchResultsDataSource

@synthesize query;

- (id)initWithController:(UITableViewController*)aController
{
    [super init];
    
    controller  = aController;
    [loadCell setType:MSG_TYPE_LOAD_FROM_WEB];

    return self;
}

- (void)dealloc {
    [query release];
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
        [self searchSubstance:false];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];   
}

- (BOOL)searchSubstance:(BOOL)reload
{
    if (twitterClient) return false;
    
    int page;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if (reload) {
        page = 0;
        insertPosition = 0;
        Message *m = [timeline messageAtIndex:0];
        if (!m) return false;
        since_id = m.messageId;
        [param setObject:[NSString stringWithFormat:@"%lld", since_id] forKey:@"since_id"];
        [param setObject:@"100" forKey:@"rpp"];
    }
    else {
        since_id = 0;
        page = ([timeline countMessages] / 15) + 1;
        insertPosition = [timeline countMessages];
    }
    
    if (latitude == 0 && longitude == 0) {
        [param setObject:self.query forKey:@"q"];
    }
    else {
        BOOL useMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        [param setObject:[NSString stringWithFormat:@"%f,%f,%d%@", latitude, longitude, distance, (useMetric) ? @"km" : @"mi"] forKey:@"geocode"];
    }
    if (page) {
        [param setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    }

    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(searchResultDidReceive:messages:)];
    [twitterClient search:param];
    return true;
}

- (int)countResults
{
    return [timeline countMessages];
}

- (void)search:(NSString*)aQuery
{ 
    [timeline removeAllMessages];
    self.query = aQuery;
    latitude = longitude = 0;
    [self searchSubstance:false];
}

- (void)geocode:(float)aLatitude longitude:(float)aLongitude distance:(int)aDistance
{
    latitude  = aLatitude;
    longitude = aLongitude;
    distance  = aDistance;
    [self searchSubstance:false];
}

- (void)searchResultDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    twitterClient = nil;
    if (![obj isKindOfClass:[NSDictionary class]]) {
        [controller noSearchResult];
    }
    
    NSDictionary *dic = (NSDictionary*)obj;
        
    NSArray *array = (NSArray*)[dic objectForKey:@"results"];

    if ([array count] == 0) {
        [controller noSearchResult];
        return;
    }
    
    [loadCell.spinner stopAnimating];
    
    // Add messages to the timeline
    for (int i = [array count] - 1; i >= 0; --i) {
        Message* m = [Message messageWithSearchResult:[array objectAtIndex:i]];
        if ([timeline indexOfObject:m] == -1) {
            [timeline insertMessage:m atIndex:insertPosition];
            if (since_id) {
                m.unread = true;
            }
        }

    }
    
    if ([controller respondsToSelector:@selector(searchDidLoad:insertAt:)]) {
        [controller searchDidLoad:[array count] insertAt:insertPosition];
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
