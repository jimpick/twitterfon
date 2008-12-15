//
//  TimelineDataSource.h
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "TwitterClient.h"
#import "LoadCell.h"

@interface TimelineDataSource : NSObject {
	Timeline*               timeline;
    TwitterClient*          twitterClient;
    LoadCell*               loadCell;
    CGPoint                 contentOffset;
}

@property(nonatomic, readonly) Timeline* timeline;
@property(nonatomic, assign) CGPoint contentOffset;

- (id)init;
- (void)cancel;
- (void)removeAllMessages;

@end
