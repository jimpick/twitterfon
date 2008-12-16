//
//  SearchResultsDataSource.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineDataSource.h"

@interface SearchResultsDataSource : TimelineDataSource <UITableViewDataSource, UITableViewDelegate> {
    UITableViewController*  controller;
    NSString*               nextPageUrl;
    NSString*               refreshUrl;
    int                     insertPosition;
    BOOL                    isReloading, isPaging;
    
    int                     since_id;
    NSString*               geocode;
}

- (id)initWithController:(UITableViewController*)controller;
- (void)search:(NSString*)query;
- (void)geocode:(float)latitude longitude:(float)longitude distance:(int)distance;
- (void)reload;
- (void)nextPage;
- (int)countResults;

@end
