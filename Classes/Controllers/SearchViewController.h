//
//  SearchViewController.h
//  TwitterFon
//
//  Created by kaz on 10/24/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendsDataSource.h"
#import "SearchHistoryDataSource.h"
#import "TimelineViewDataSource.h"
#import "LocationManager.h"
#import "OverlayView.h"
#import "CustomSearchBar.h"

@interface SearchViewController : UITableViewController <UITextFieldDelegate, CustomSearchBarDelegate, UIPickerViewDelegate> {
    CustomSearchBar*            searchBar;
    UIBarButtonItem*            trendsButton;
    UIBarButtonItem*            reloadButton;
    TrendsDataSource*           trends;
    TimelineViewDataSource*     search;
    SearchHistoryDataSource*    history;
    IBOutlet UITableView*       searchView;
    OverlayView*                overlayView;
    int                         unread;
    BOOL                        isReload;
    
    float                       latitude, longitude;
}

- (void)search:(NSString*)query;
- (void)reloadTable;

@end
