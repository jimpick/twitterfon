//
//  SearchViewController.h
//  TwitterFon
//
//  Created by kaz on 10/24/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendsDataSource.h"
#import "SearchResultDataSource.h"
#import "SearchHistoryDataSource.h"
#import "LocationManager.h"

@interface SearchViewController : UITableViewController <UISearchBarDelegate> {
    UISearchBar*                searchBar;
    TrendsDataSource*           trends;
    SearchResultDataSource*     search;
    SearchHistoryDataSource*    history;
    LocationManager*            location;
}

- (void)search:(NSString*)query;

@end
