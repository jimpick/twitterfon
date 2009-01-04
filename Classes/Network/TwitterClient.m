//
//  TwitterClient.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "DirectMessage.h"
#import "TwitterClient.h"
#import "StringUtil.h"
#import "JSON.h"

static 
NSString* sMethods[4] = {
    @"statuses/friends_timeline",
    @"statuses/replies",
    @"direct_messages",
    @"direct_messages/sent",
};

@implementation TwitterClient

@synthesize request;
@synthesize context;
@synthesize hasError;
@synthesize errorMessage;
@synthesize errorDetail;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction
{
    [super initWithDelegate:aDelegate];
    action = anAction;
    hasError = false;
    return self;
}

- (void)dealloc
{
    [errorMessage release];
    [errorDetail release];
    [super dealloc];
}

- (void)getTimeline:(TweetType)type params:(NSDictionary*)params
{
    request = type;
    needAuth = true;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/%@.json", sMethods[type]];
    
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

- (void)getUserTimeline:(NSString*)screen_name params:(NSDictionary*)params
{
    needAuth = true;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/statuses/user_timeline/%@.json", screen_name];
    
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

- (void)getUser:(NSString*)screen_name
{
    needAuth = true;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/users/show/%@.json", screen_name];
    [super get:url];
}

- (void)getMessage:(sqlite_int64)statusId
{
    needAuth = true;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/statuses/show/%lld.json", statusId];
    [super get:url];
}

- (void)post:(NSString*)tweet inReplyTo:(sqlite_int64)statusId
{
    needAuth = true;
    
    NSString* url = @"https://twitter.com/statuses/update.json";
    NSString *postString = [NSString stringWithFormat:@"status=%@&in_reply_to_status_id=%lld&source=twitterfon",
                            [tweet encodeAsURIComponent],
                            statusId];

    [self post:url body:postString];
    
}

- (void)send:(NSString*)text to:(NSString*)user
{
    needAuth = true;
    NSString* url = @"https://twitter.com/direct_messages/new.json";
    
    NSString *postString = [NSString stringWithFormat:@"text=%@&user=%@", [text encodeAsURIComponent], [user encodeAsURIComponent]];
    
    [self post:url body:postString];
    
}

- (void)getFriends:(NSString*)screen_name page:(int)page isFollowers:(BOOL)isFollowers
{
    needAuth = true;
    NSString* url = [NSString stringWithFormat:@"https://twitter.com/statuses/%@/%@.json?page=%d",
                    (isFollowers) ? @"followers" : @"friends", [screen_name encodeAsURIComponent], page];
    
    [self get:url];

}

- (void)friendship:(NSString*)screen_name create:(BOOL)create
{
    needAuth = true;
    request = (create) ? TWITTER_REQUEST_CREATE_FRIENDSHIP : TWITTER_REQUEST_DESTROY_FRIENDSHIP;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/friendships/%@/%@.json",
                     create ? @"create" : @"destroy",
                     screen_name];

    [self post:url body:@""];
}

- (void)existFriendship:(NSString*)screen_name
{
    needAuth = true;
    request = TWITTER_REQUEST_FRIENDSHIP_EXISTS;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    NSString *url = [NSString stringWithFormat:@"http://twitter.com/friendships/exists.json?user_a=%@&user_b=%@",
                     [username encodeAsURIComponent],
                     [screen_name encodeAsURIComponent]];
    
    [self post:url body:@""];
}

- (void)destroy:(Tweet*)tweet
{
    needAuth = true;

    NSString *url;
    if ([tweet isKindOfClass:[Status class]]) {
        Status *status = (Status*)tweet;
        url = [NSString stringWithFormat:@"https://twitter.com/statuses/destroy/%lld.json", [status  statusId]];
    }
    else {
        DirectMessage *message = (DirectMessage*)tweet;
        url = [NSString stringWithFormat:@"https://twitter.com/direct_messages/destroy/%lld.json", [message messageId]];
    }
    
    [self post:url body:@""];
}

- (void)favorites:(NSString*)screenName page:(int)page
{
    needAuth = true;
    NSString *url;
    
    if (screenName) {
        url = [NSString stringWithFormat:@"https://twitter.com/favorites/%@.json?page=%d", screenName, page];
    }
    else {
        url = @"https://twitter.com/favorites.json";
    }
    
    [self get:url];
}

- (void)toggleFavorite:(Status*)status
{
    needAuth = true;
    request = (status.favorited) ? TWITTER_REQUEST_DESTROY_FAVORITE : TWITTER_REQUEST_FAVORITE;
    
    NSString* url = [NSString stringWithFormat:@"https://twitter.com/favorites/%@/%lld.json",
                     (status.favorited) ? @"destroy" : @"create",
                     [status statusId]];
    
    [self post:url body:@""];    
}

- (void)updateLocation:(float)latitude longitude:(float)longitude
{
    needAuth = true;
    
	NSString* url = @"https://twitter.com/account/update_location.json";
    
    NSString *postString = [NSString stringWithFormat:@"location=iPhone: %f,%f", latitude, longitude];
    
    [self post:url body:postString];
}

- (void)search:(NSString*)query
{
    NSMutableString *url = [NSMutableString stringWithString:@"http://search.twitter.com/search.json"];
    [url appendString:query];
    [self get:url];
}

- (void)trends
{
    [super get:@"http://search.twitter.com/trends.json"];
}

- (void)verify
{
    needAuth = true;
	NSString* url = @"https://twitter.com/account/verify_credentials.json";
    
    [super get:url];
}

- (void)authError
{
    self.errorMessage = @"Authentication Failed";
    self.errorDetail  = @"Wrong username/Email and password combination.";    
    [delegate performSelector:action withObject:self withObject:nil];    
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    hasError = true;
    if (error.code ==  NSURLErrorUserCancelledAuthentication) {
        statusCode = 401;
        [self authError];
    }
    else {
        self.errorMessage = @"Connection Failed";
        self.errorDetail  = [error localizedDescription];
        [delegate performSelector:action withObject:self withObject:nil];
    }
    [self autorelease];
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
    hasError = true;
    [self authError];
    [self autorelease];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            hasError = true;
            [self authError];
            goto out;
            
        case 304: // Not Modified: there was no new data to return.
            [delegate performSelector:action withObject:self withObject:nil];
            goto out;
            
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
            hasError = true;
            self.errorMessage = @"Server responded with an error";
            self.errorDetail  = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
            [delegate performSelector:action withObject:self withObject:nil];
            goto out;
        }
    }
#if 0
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathStr;
    if (request == 0) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"friends_timeline.json"];
    }
    else if (request == 1) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"replies.json"];
    }
    else if (request == 2) {
        pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"direct_messages.json"];
    }
    if (request <= 2) {
        NSData *data = [fileManager contentsAtPath:pathStr];
        content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
#endif

    NSObject *obj = [content JSONValue];
    if (request == TWITTER_REQUEST_FRIENDSHIP_EXISTS) {
        NSRange r = [content rangeOfString:@"true" options:NSCaseInsensitiveSearch];
  	  	obj = [NSNumber numberWithBool:r.location != NSNotFound];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"Twitter responded with an error: %@", msg);
            hasError = true;
            self.errorMessage = @"Twitter Server Error";
            self.errorDetail  = msg;
        }
    }
    
    [delegate performSelector:action withObject:self withObject:obj];
    
  out:
    [self autorelease];
}

- (void)alert
{
    [[TwitterFonAppDelegate getAppDelegate] alert:errorMessage message:errorDetail];
}

@end
