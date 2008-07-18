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

//#define USE_LOACAL_FILE
//#define DEBUG_WITH_PUBLIC_TIMELINE

@interface NSObject (TimelineDownloaderDelegate)
- (void)timelineDownloaderDidSucceed:(TimelineDownloader*)sender messages:(NSArray*)messages;
- (void)timelineDownloaderDidFail:(TimelineDownloader*)sender error:(NSError*)error;
@end

@implementation TimelineDownloader

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

- (BOOL)active
{
	return conn != nil;
}

- (void)get:(NSString*)aMethod
{
	[conn release];
	[buf release];

	// for debug
#ifdef USE_LOCAL_FILE
	NSString* s = [NSString stringWithContentsOfFile:@"/Users/psychs/Desktop/response.txt"];
	buf = [[s dataUsingEncoding:NSUTF8StringEncoding] retain];
	[self connectionDidFinishLoading:nil];
#else

#ifdef DEBUG_WITH_PUBLIC_TIMELINE
	NSString* url = @"http://twitter.com/statuses/public_timeline.json";
#else

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    method = aMethod;

	NSString* url = [NSString stringWithFormat:@"https://%@:%@@twitter.com/%@.json",
                              username,
                              password,
                              method];

    NSLog(@"%@", url);
#endif

	url = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
														cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														timeoutInterval:60.0];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	buf = [[NSMutableData data] retain];

#endif
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if (res) {
        NSLog(@"Status: %d", res.statusCode);
        status = res.statusCode;

        switch (status) {

        case 400:
            [self showDialog:@"Rate limit exceeded" withMessage:@"Client may not access twitter 100 times per hours."];
            break;
            
        case 401:
            [self showDialog:@"Authentication Failed" withMessage:@"Wrong username/Email and password combination."];
            break;

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
            NSString *msg = [NSString stringWithFormat:@"Twitter server responded with an error (code: %d)", status];
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
	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;

    NSString *msg = [NSString stringWithFormat:@"Error: %@ (request: %@)",
                              [error localizedDescription], method];

    [self showDialog:@"Connection Failed" withMessage:msg];

    msg = [NSString stringWithFormat:@"Error: %@ %@",
                    [error localizedDescription],
                    [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];

    NSLog(@"Connection failed! %@", msg);

	
	if (delegate && [delegate respondsToSelector:@selector(timelineDownloaderDidFail:error:)]) {
		[delegate timelineDownloaderDidFail:self error:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{

    if (status != 200) {
        [conn autorelease];
        conn = nil;
        [buf autorelease];
        buf = nil;
    }

	NSString* s = [[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding];
	
	NSArray* ary = [s JSONValue];
	NSMutableArray* messages = [NSMutableArray array];
	
	int i;
	for (i=[ary count]-1; i >= 0; --i) {
		Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i]];
		[messages addObject:m];
	}
	
	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;
	
	if (delegate && [delegate respondsToSelector:@selector(timelineDownloaderDidSucceed:messages:)]) {
		[delegate timelineDownloaderDidSucceed:self messages:messages];
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
