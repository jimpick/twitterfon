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
    NSString*               query;
    float                   latitude, longitude;
    int                     distance;
    int                     insertPosition;
    uint64_t                since_id;

}

@property(nonatomic, copy) NSString* query;

- (id)initWithController:(UITableViewController*)controller;
- (BOOL)searchSubstance:(BOOL)reload;
- (void)search:(NSString*)query;
- (void)geocode:(float)latitude longitude:(float)longitude distance:(int)distance;
- (int)countResults;

@end
