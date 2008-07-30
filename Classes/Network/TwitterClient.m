//
//  TwitterClient.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterClient.h"
#import "StringUtil.h"
#import "JSON.h"
#import "Message.h"

static 
NSString* sMethods[3] = {
    @"statuses/friends_timeline",
    @"statuses/replies",
    @"direct_messages",
};

//#define DEBUG_WITH_PUBLIC_TIMELINE

@interface NSObject (TwitterClientDelegate)
- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)messages;
- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error;
@end

@implementation TwitterClient

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

- (void)post:(NSString*)tweet
{
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
	NSString* url = [NSString stringWithFormat:@"https://%@:%@@twitter.com/statuses/update.json",
                     username, password];
    
    NSLog(@"%@", url);
    
    NSString *postString = [NSString stringWithFormat:@"status=%@&source=twitterfon", [tweet encodeAsURIComponent]];
    
    [self post:url body:postString];
    
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    [self alertError:@"Connection Failed" withMessage:[error localizedDescription]];
    [delegate twitterClientDidFail:self error:[error localizedDescription]];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            [self alertError:@"Authentication Failed" withMessage:@"Wrong username/Email and password combination."];
            [delegate twitterClientDidFail:self error:@"Wrong username/Email and password combination."];
            return;
            
        case 304: // Not Modified: there was no new data to return.
            [delegate twitterClientDidSucceed:self messages:nil];
            return;

        case 400: // Bad Request: your request is invalid, and we'll return an error message that tells you why. This is the status code returned if you've exceeded the rate limit
        case 200: // OK: everything went awesome.
        case 403: // Forbidden: we understand your request, but are refusing to fulfill it.  An accompanying error message should explain why.
            break;
                
        case 404: // Not Found: either you're requesting an invalid URI or the resource in question doesn't exist (ex: no such user). 
        case 500: // Internal Server Error: we did something wrong.  Please post to the group about it and the Twitter team will investigate.
        case 502: // Bad Gateway: returned if Twitter is down or being upgraded.
        case 503: // Service Unavailable: the Twitter servers are up, but are overloaded with requests.  Try again later.
        default:
        {
            NSString *msg = [NSString stringWithFormat:@"%@ responded %d", response.URL.host, statusCode];
            [self alertError:@"Server responded with an error" withMessage:msg];
            [delegate twitterClientDidFail:self error:msg];            
            return;
        }
    }
    
    NSObject* obj = [content JSONValue];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"Twitter responded with an error: %@", msg);
            [self alertError:@"Server error" withMessage:msg];
            [delegate twitterClientDidFail:self error:msg];
        }
        else {
            [delegate twitterClientDidSucceed:self messages:obj];
        }
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        [delegate twitterClientDidSucceed:self messages:obj];
    }
    else {
        NSLog(@"Null or wrong response: %@", content);
        [delegate twitterClientDidSucceed:self messages:nil];
    }
}

@end
