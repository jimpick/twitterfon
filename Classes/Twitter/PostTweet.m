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

@interface PostTweet (Private)
- (void)showDialog:(NSString*)title withMessage:(NSString*)msg;
@end

@interface NSObject (PostTweetDelegate)
- (void)postTweetDidSucceed:(PostTweet*)sender message:(Message*)messages;
- (void)postTweetDidFail:(PostTweet*)sender error:(NSError*)error;
@end

@implementation PostTweet

- (id)initWithDelegate:(NSObject*)aDelegate
{
	self = [super init];
	delegate = aDelegate;
	return self;
}

- (void)dealloc
{
	[conn release];
	[buf release];
	[super dealloc];
}

- (void)post:(NSString*)tweet
{
	[conn release];
	[buf release];

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

	NSString* url = [NSString stringWithFormat:@"https://%@:%@@twitter.com/statuses/update.json",
                     username, password];

    NSLog(@"%@", url);
    
    NSString *postString = [NSString stringWithFormat:@"status=%@&source=TwitterFon", [tweet encodeAsURIComponent]];
    
	url = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
													timeoutInterval:60.0];
    
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    int contentLength = [postString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    [req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[NSData dataWithBytes:[postString UTF8String] length:contentLength]];
    
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	buf = [[NSMutableData data] retain];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if (res) {
        NSLog(@"Post finish: %d", res.statusCode);

        switch (res.statusCode) {

        case 401:
            [self showDialog:@"Authentication Failed" withMessage:@"Wrong username/Email and password combination."];
            break;

        case 400:
        case 200:
        case 304:
            break;

        case 403:
        case 404:
        case 500:
        case 502:
        case 503:
        default:
        {
            NSString *msg = [NSString stringWithFormat:@"Twitter server responded with an error (code: %d)", res.statusCode];
            [self showDialog:@"Server responded an error" withMessage:msg];
            break;
        }
        }
    }
    
    
	[buf setLength:0];
}

- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
	[buf appendData:data];
}

- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;

    NSString *msg = [NSString stringWithFormat:@"Can't send tweet: %@", [error localizedDescription]];

    [self showDialog:@"Connection Failed" withMessage:msg];

    msg = [NSString stringWithFormat:@"Error: %@ %@",
                    [error localizedDescription],
                    [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];

    NSLog(@"Connection failed! %@", msg);

	
	if (delegate && [delegate respondsToSelector:@selector(postTweetDidFail:error:)]) {
		[delegate postTweetDidFail:self error:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	NSString* s = [[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding];
    [conn autorelease];
    conn = nil;
    [buf autorelease];
    buf = nil;
	
	NSObject* obj = [s JSONValue];

    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"%@", s);
            if (msg == nil) msg = @"";
            NSLog(@"Twitter returns an error: %@", msg);
            [self showDialog:@"Server error" withMessage:msg];
        }
        else {
            Message* m = [Message messageWithJsonDictionary:dic type:MSG_TYPE_FRIENDS];
            if (delegate && [delegate respondsToSelector:@selector(postTweetDidSucceed:message:)]) {
                [delegate postTweetDidSucceed:self message:m];
            }
        }
    }
}

- (void)showDialog:(NSString*)title withMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                              message:msg
                                              delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
            [alert show];	
            [alert release];
}


@end
