//
//  TimelineDataSource.m
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TimelineDataSource.h"
#import "TwitterFonAppDelegate.h"

@implementation TimelineDataSource

@synthesize timeline;
@synthesize contentOffset;

- (id)init
{
    [super init];
    loadCell = [[LoadCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"LoadCell"];
    timeline   = [[Timeline alloc] init];
    return self;
}

- (void)dealloc {
    [twitterClient cancel];
    [twitterClient release];
    [loadCell release];
    [timeline release];
	[super dealloc];
}

- (void)cancel
{
    if (twitterClient) {
        [twitterClient cancel];
        twitterClient = nil;
    }
}

- (void)removeAllStatuses
{
    [timeline removeAllStatuses];
}

@end
