//
//  TimelineDownloader.m
//  TwitterPhox
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TimelineDownloader.h"
#import "JSON.h"
#import "Message.h"

static 
NSString* sMethods[3] = {
    @"statuses/friends_timeline",
    @"statuses/replies",
    @"direct_messages",
};

//#define DEBUG_WITH_PUBLIC_TIMELINE

@interface NSObject (TimelineDownloaderDelegate)
- (void)timelineDownloaderDidSucceed:(TimelineDownloader*)sender messages:(NSArray*)messages;
- (void)timelineDownloaderDidFail:(TimelineDownloader*)sender error:(NSError*)error;
@end

@implementation TimelineDownloader

- (void)get:(MessageType)type since:(NSString*)since
{
#ifdef DEBUG_WITH_PUBLIC_TIMELINE
	NSString* url = @"http://twitter.com/statuses/public_timeline.json";
#else
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

	NSString* url = [NSString stringWithFormat:@"https://%@:%@@twitter.com/%@.json",
                     username,
                     password,
                     sMethods[type]];

    //
    // Convert MySQL date format to HTTP date
    //
    if (since) {
        struct tm time;
        char timestr[128];
        setenv("TZ", "GMT", 1);
        strptime([since UTF8String], "%a %b %d %H:%M:%S %z %Y", &time);
        strftime(timestr, 128, "%a, %d %b %Y %H:%M:%S GMT", &time);
        url = [NSString stringWithFormat:@"%@?since=%s", url, timestr];
    }

#endif
    
    [super get:url];
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response
{
    [super connection:aConn didReceiveResponse:response];
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if (res.statusCode == 401) {
        [self alertError:@"Authentication Failed" withMessage:@"Wrong username/Email and password combination."];
    }
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    [self alertError:@"Connection Failed" withMessage:[error localizedDescription]];
    [delegate timelineDownloaderDidFail:self error:error];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    NSObject* obj = [content JSONValue];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@", content);
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg == nil) msg = @"";
        NSLog(@"Twitter returns an error: %@", msg);
        [self alertError:@"Server error" withMessage:msg];
		[delegate timelineDownloaderDidFail:self error:nil];
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *ary = (NSArray*)obj;
        NSLog(@"received %d objects", [ary count]);
        [delegate timelineDownloaderDidSucceed:self messages:ary];
    }
    else {
        NSLog(@"Null or wrong response: %@", content);
        [delegate timelineDownloaderDidSucceed:self messages:nil];
    }
}

@end
