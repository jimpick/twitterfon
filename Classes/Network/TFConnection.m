//
//  Connection.m
//  TwitterFon
//
//  Created by kaz on 7/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TFConnection.h"

@implementation TFConnection

@synthesize buf;

- (id)initWithDelegate:(NSObject*)aDelegate
{
	self = [super init];
	delegate = aDelegate;
    statusCode = 0;
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
    [conn release];
	[buf release];

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

-(void)post:(NSString*)aURL body:(NSString*)body
{
    [conn release];
	[buf release];

    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aURL, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:60.0];
    
    
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    int contentLength = [body lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    [req setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:[NSData dataWithBytes:[body UTF8String] length:contentLength]];
    
	buf = [[NSMutableData data] retain];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)aResponse
{
    response = (NSHTTPURLResponse*)aResponse;
    if (response) {
        statusCode = response.statusCode;
        NSLog(@"Response: %d", statusCode);
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
    
    NSString* msg = [NSString stringWithFormat:@"Error: %@ %@",
                     [error localizedDescription],
                     [[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
    
    NSLog(@"Connection failed: %@", msg);
    
    [self TFConnectionDidFailWithError:error];
    
}


- (void)TFConnectionDidFailWithError:(NSError*)error
{
    // To be implemented in subclass
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* s = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] autorelease];
    
    [self TFConnectionDidFinishLoading:s];

    [conn autorelease];
    conn = nil;
    [buf autorelease];
    buf = nil;
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    // To be implemented in subclass
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
