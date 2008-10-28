//
//  TwitterClient.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "TwitterClient.h"
#import "StringUtil.h"
#import "JSON.h"
#import "Message.h"

static 
NSString* sMethods[4] = {
    @"statuses/friends_timeline",
    @"statuses/replies",
    @"direct_messages",
    @"statuses/user_timeline",
};

@interface NSObject (TwitterClientDelegate)
- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)messages;
- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail;
@end

@implementation TwitterClient

@synthesize request;
@synthesize context;

- (void)get:(MessageType)type params:(NSDictionary*)params
{
    request = TWITTER_REQUEST_TIMELINE;
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
        
    NSString *url;
    if (type == MSG_TYPE_USER) {
        // No need authentication because already has a cookie
        url = @"http://twitter.com/statuses/user_timeline.json";
    }
    else {
        url = [NSString stringWithFormat:@"http://%@:%@@twitter.com/%@.json",
               [username encodeAsURIComponent],
               [password encodeAsURIComponent],
               sMethods[type]];
    }
    
    int i = 0;
    for (id key in params) {
        NSString *value = [params objectForKey:key];
        if (i == 0) {
            url = [NSString stringWithFormat:@"%@?%@=%@", url, key, value];
        }
        else {
            url = [NSString stringWithFormat:@"%@&%@=%@", url, key, value];
        }
        ++i;
    }
    [super get:url];
}

- (void)post:(NSString*)tweet
{
    request = TWITTER_REQUEST_UPDATE;
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

	NSString* url = [NSString stringWithFormat:@"http://%@:%@@twitter.com/statuses/update.json",
                     [username encodeAsURIComponent], [password encodeAsURIComponent]];
    
    NSLog(@"%@", url);
    
    NSString *postString = [NSString stringWithFormat:@"status=%@&source=twitterfon", [tweet encodeAsURIComponent]];
    
    [self post:url body:postString];
    
}

- (void)destroy:(Message*)message
{
    request = TWITTER_REQUEST_DESTROY;
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
	NSString* url = [NSString stringWithFormat:@"http://%@:%@@twitter.com/statuses/destroy/%lld.json",
                     [username encodeAsURIComponent], [password encodeAsURIComponent], [message messageId]];
    
    NSLog(@"%@", url);
    
    [self post:url body:@""];
}

- (void)favorite:(Message*)message
{
    request = (message.favorited) ? TWITTER_REQUEST_DESTROY : TWITTER_REQUEST_FAVORITE;
    
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    NSString* url = [NSString stringWithFormat:@"http://%@:%@@twitter.com/favorites/%@/%lld.json",
                     [username encodeAsURIComponent],
                     [password encodeAsURIComponent],
                     (message.favorited) ? @"destroy" : @"create",
                     [message messageId]];
    
    NSLog(@"%@", url);
    
    [self post:url body:@""];    
}

- (void)search:(NSString*)query
{
    NSString* url = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%@",  [query encodeAsURIComponent]];
    [self get:url];
}

- (void)geocode:(float)latitude longitude:(float)longitude distance:(int)distance
{
    NSString* url = [NSString stringWithFormat:@"http://search.twitter.com/search.json?geocode=%f,%f,%dmi",
                     latitude, longitude, distance];
    [super get:url];
}

- (void)trends
{
    [super get:@"http://search.twitter.com/trends.json"];
}

- (void)verify
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
	NSString* url = [NSString stringWithFormat:@"http://%@:%@@twitter.com/account/verify_credentials.json",
                     [username encodeAsURIComponent], [password encodeAsURIComponent]];
    
    NSLog(@"%@", url);
    
    [super get:url];
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    if (error.code ==  NSURLErrorUserCancelledAuthentication) {
        [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];

        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate openSettingsView];
    }
    else {
        [delegate twitterClientDidFail:self error:@"Connection Failed" detail:[error localizedDescription]];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) {
        NSLog(@"Authentication Challenge");
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
		NSURLCredential* cred = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceNone];
		[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
	} else {
		NSLog(@"Failed auth (%d times)", [challenge previousFailureCount]);
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
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
            [delegate twitterClientDidFail:self error:@"Server responded with an error" detail:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
            return;
        }
    }
    
    NSObject* obj = [content JSONValue];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"Twitter responded with an error: %@", msg);
            [delegate twitterClientDidFail:self error:@"Server error" detail:msg];
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
