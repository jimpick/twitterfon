//
//  TinyURL.m
//  TwitterFon
//
//  Created by kaz on 7/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TinyURL.h"

#define TINYURL_ENCODE_URL @"http://tinyurl.com/api-create.php?url=%@"

@interface NSObject (TinyURLDelegater)
- (void)decodeTinyURLDidSucceed:(NSString*)tinyURL URL:(NSString*)URL;
- (void)encodeTinyURLDidSucceed:(NSString*)tinyURL URL:(NSString*)URL;
- (void)tinyURLDidFail:(TinyURL*)sender error:(NSString*)error;
@end

@implementation TinyURL

@synthesize givenURL;

+ (BOOL)needToDecode:(NSString*)anURL
{
    if (anURL == nil) return false;
    
    NSRange r = [anURL rangeOfString:@"tinyurl.com"];
    if (r.location != NSNotFound) {
        return false;
    }
    return ([anURL length] > 30) ? true : false;
    
}

- (void)decode:(NSString*)tinyURL
{
}

- (void)encode:(NSString*)anURL
{
    self.givenURL = anURL;
    NSString* url = [NSString stringWithFormat:TINYURL_ENCODE_URL, anURL];
    [self get:url];
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    [delegate tinyURLDidFail:self error:[error localizedDescription]];
    [self autorelease];
}   

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    if (statusCode == 200) {
        [delegate encodeTinyURLDidSucceed:content URL:givenURL];
    }
    else {
        [delegate tinyURLDidFail:self error:[NSString stringWithFormat:@"tinyURL server responded with %d", statusCode]];
    }
    [self autorelease];
}

- (void)dealloc
{
    [givenURL release];
    [super dealloc];
}


@end
