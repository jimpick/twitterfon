//
//  SearchHistoryDataSource.h
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchHistoryDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray* queries;
    id              delegate;
}

- (id)initWithDelegate:(id)delegate;
- (void)updateQuery:(NSString*)query;
- (void)removeAllQueries;

@end
