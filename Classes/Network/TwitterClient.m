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
NSString* sMethods[4] = {
    @"statuses/friends_timeline",
    @"statuses/replies",
    @"direct_messages",
    @"direct_messages/sent",
};

@interface NSObject (TwitterClientDelegate)
- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)messages;
- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail;
@end

@implementation TwitterClient

@synthesize request;
@synthesize context;

- (id)initWithTarget:(id)aDelegate action:(SEL)anAction
{
    [super initWithDelegate:aDelegate];
    action = anAction;
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)getTimeline:(MessageType)type params:(NSDictionary*)params
{
    needAuth = true;
    request = TWITTER_REQUEST_TIMELINE;
    
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
    request = TWITTER_REQUEST_TIMELINE;
    
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
    request = TWITTER_REQUEST_USER;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/users/show/%@.json", screen_name];
    [super get:url];
}

- (void)getMessage:(sqlite_int64)messageId
{
    needAuth = true;
    request = TWITTER_REQUEST_MESSAGE;
    NSString *url = [NSString stringWithFormat:@"https://twitter.com/statuses/show/%lld.json", messageId];
    [super get:url];
}

- (void)post:(NSString*)tweet inReplyTo:(sqlite_int64)messageId
{
    needAuth = true;
    request = TWITTER_REQUEST_UPDATE;
    
    NSString* url = @"https://twitter.com/statuses/update.json";
    NSString *postString = [NSString stringWithFormat:@"status=%@&in_reply_to_status_id=%lld&source=twitterfon",
                            [tweet encodeAsURIComponent],
                            messageId];

    NSLog(@"%@", postString);
    [self post:url body:postString];
    
}

- (void)send:(NSString*)text to:(NSString*)user
{
    needAuth = true;
    request = TWITTER_REQUEST_SEND_DIRECT_MESSAGE;
    
    NSString* url = @"https://twitter.com/direct_messages/new.json";
    
    NSString *postString = [NSString stringWithFormat:@"text=%@&user=%@", [text encodeAsURIComponent], [user encodeAsURIComponent]];
    
    [self post:url body:postString];
    
}

- (void)getFriends:(NSString*)screen_name page:(int)page isFollowers:(BOOL)isFollowers
{
    needAuth = true;
    request = (isFollowers) ? TWITTER_REQUEST_FOLLOWERS_LIST : TWITTER_REQUEST_FRIENDS_LIST;
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

    NSLog(@"%@", url);
    
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

- (void)destroy:(Message*)message isDirectMessage:(BOOL)isDirectMessage
{
    needAuth = true;
    request = TWITTER_REQUEST_DESTROY_MESSAGE;

    NSString *url;
    if (isDirectMessage) {
        url = [NSString stringWithFormat:@"https://twitter.com/direct_messages/destroy/%lld.json", [message messageId]];
    }
    else {
        url = [NSString stringWithFormat:@"https://twitter.com/statuses/destroy/%lld.json", [message messageId]];
    }
    
    NSLog(@"%@", url);
    
    [self post:url body:@""];
}

- (void)favorite:(Message*)message
{
    needAuth = true;
    request = (message.favorited) ? TWITTER_REQUEST_DESTROY_FAVORITE : TWITTER_REQUEST_FAVORITE;
    
    NSString* url = [NSString stringWithFormat:@"https://twitter.com/favorites/%@/%lld.json",
                     (message.favorited) ? @"destroy" : @"create",
                     [message messageId]];
    
    NSLog(@"%@", url);
    
    [self post:url body:@""];    
}

- (void)updateLocation:(float)latitude longitude:(float)longitude
{
    needAuth = true;
    request = TWITTER_REQUEST_UPDATE_LOCATION;
    
	NSString* url = @"https://twitter.com/account/update_location.json";
    
    NSLog(@"%@", url);
    
    NSString *postString = [NSString stringWithFormat:@"location=iPhone: %f,%f", latitude, longitude];
    
    [self post:url body:postString];
}

- (void)search:(NSDictionary*)params
{
    NSString* url = @"http://search.twitter.com/search.json";

    int i = 0;
    for (id key in params) {
        NSString *value = [params objectForKey:key];
        if (i == 0) {
            url = [NSString stringWithFormat:@"%@?%@=%@", url, key, [value encodeAsURIComponent]];
        }
        else {
            url = [NSString stringWithFormat:@"%@&%@=%@", url, key, [value encodeAsURIComponent]];
        }
        ++i;
    }
    [self get:url];
}

- (void)searchWithQueryString:(NSString*)query
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

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    if (error.code ==  NSURLErrorUserCancelledAuthentication) {
        statusCode = 401;
        [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
    }
    else {
        [delegate twitterClientDidFail:self error:@"Connection Failed" detail:[error localizedDescription]];
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
    [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
    [self autorelease];
}

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    switch (statusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            [delegate twitterClientDidFail:self error:@"Authentication Failed" detail:@"Wrong username/Email and password combination."];
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
            [delegate twitterClientDidFail:self error:@"Server responded with an error" detail:[NSHTTPURLResponse localizedStringForStatusCode:statusCode]];
            goto out;
        }
    }
#if 0
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"null_friends_timelne.json"];
    NSData *data = [fileManager contentsAtPath:path];
    content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#endif

    NSObject *obj = [content JSONValue];
    if (request == TWITTER_REQUEST_FRIENDSHIP_EXISTS) {
        obj = [NSNumber numberWithBool:[content isEqualToString:@"\"true\""]];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)obj;
        NSString *msg = [dic objectForKey:@"error"];
        if (msg) {
            NSLog(@"Twitter responded with an error: %@", msg);
            [delegate twitterClientDidFail:self error:@"Server error" detail:msg];
        }
        else {
            [delegate performSelector:action withObject:self withObject:obj];
        }
    }
    else {
        [delegate performSelector:action withObject:self withObject:obj];
    }
    
  out:
    [self autorelease];
}

@end
