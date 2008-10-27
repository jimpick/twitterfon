//
//  SearchResultDataSource.h
//  TwitterFon
//
//  Created by kaz on 10/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "ImageStore.h"

@interface SearchResultDataSource : NSObject <UITableViewDataSource, UITableViewDelegate> {
    Timeline*       timeline;
    id              delegate;
    ImageStore*     imageStore;
}

- (id)initWithDelegate:(id)delegate;
- (void)removeAllResults;
- (void)search:(NSString*)query;
- (void)geocode:(float)latitude longitude:(float)longitude;

@end
