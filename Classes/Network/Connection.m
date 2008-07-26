//
//  Connection.m
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Connection.h"

@interface NSObject (ConnectionDelegate)
- (void)connectionDidSucceed:(Connection*)sender content:(NSString*)content;
- (void)connectionDidFail:(Connection*)sender error:(NSError*)error;
@end

@interface Connection (Private)
- (void)alertError:(NSString*)title withMessage:(NSString*)msg;
@end

@implementation Connection

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


- (void)get:(NSString*)aURL
{
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
    NSLog(@"%@", URL);
	NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]
                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                     timeoutInterval:60.0];
	buf  = [[NSMutableData data] retain];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)post
{
}


- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if (res) {
        NSLog(@"Response: %d", res.statusCode);
        switch (res.statusCode) {
                
            case 401:
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
                NSString *msg = [NSString stringWithFormat:@"%@ responded %d", response.URL.host, res.statusCode];
                [self alertError:@"Server responded an error" withMessage:msg];
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
    
    [self alertError:@"Connection Failed" withMessage:[error localizedDescription]];
    
    NSString* msg = [NSString stringWithFormat:@"Error: %@ %@",
                     [error localizedDescription],
                     [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
    
    NSLog(@"Connection failed: %@", msg);
    
	
	if (delegate && [delegate respondsToSelector:@selector(connectionDidFail:error:)]) {
		[delegate connectionDidFail:self error:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* s = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding]autorelease];
    [conn autorelease];
    conn = nil;
    [buf autorelease];
    buf = nil;
    
    if (delegate && [delegate respondsToSelector:@selector(connectionDidSucceed:content:)]) {
        [delegate connectionDidSucceed:self content:s];
    }    
}

- (void)alertError:(NSString*)title withMessage:(NSString*)msg
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
