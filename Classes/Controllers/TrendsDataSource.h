//
//  TrendsDataSource.h
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendsDataSource : NSObject<UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray*         trends;
    id                      delegate;
}

- (id)initWithDelegate:(id)delegate;
- (void)getTrends;

@end
