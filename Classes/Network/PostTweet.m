//
//  TimelineDownloader.m
//  TwitterPhox
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "PostTweet.h"
#import "JSON.h"
#import "Message.h"
#import "StringUtil.h"

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)dic;
- (void)postTweetDidFail:(NSString*)error;
@end

@implementation PostTweet

- (void)post:(NSString*)tweet
{

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

	NSString* url = [NSString stringWithFormat:@"https://%@:%@@twitter.com/statuses/update.json",
                     username, password];

    NSLog(@"%@", url);
    
    NSString *postString = [NSString stringWithFormat:@"status=%@&source=TwitterFon", [tweet encodeAsURIComponent]];
    
    [self post:url body:postString];
    
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
    NSString *errorMessage = [error localizedDescription];
    if (delegate && [delegate respondsToSelector:@selector(postTweetDidFail:)]) {
		[delegate postTweetDidFail:errorMessage];
	}
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
	NSObject* obj = [content JSONValue];

    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"%@", content);
            if (msg == nil) msg = @"";
            NSLog(@"Twitter returns an error: %@", msg);
            [delegate postTweetDidFail:msg];
        }
        else {
            [delegate postTweetDidSucceed:dic];
        }
    }
    else {
        NSLog(@"%@", content);
        [delegate postTweetDidFail:@""];
    }
}

@end
