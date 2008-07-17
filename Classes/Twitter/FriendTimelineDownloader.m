#import "FriendTimelineDownloader.h"
#import "JSON.h"
#import "Message.h"

#define PASSWORD @"phoenix"

@interface NSObject (FriendTimelineDownloaderDelegate)
- (void)friendTimelineDownloaderDidSucceed:(FriendTimelineDownloader*)sender messages:(NSArray*)messages;
- (void)friendTimelineDownloaderDidFail:(FriendTimelineDownloader*)sender error:(NSError*)error;
@end


@implementation FriendTimelineDownloader

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

- (void)get
{
	[conn release];
	[buf release];

	// for debug
//*
	NSString* s = [NSString stringWithContentsOfFile:@"/Users/psychs/Desktop/response.txt"];
	buf = [[s dataUsingEncoding:NSUTF8StringEncoding] retain];
	[self connectionDidFinishLoading:nil];
//*/
	
//*
	//NSString* url = @"http://limechat.net/statuses/friends_timeline.json";
	NSString* url = @"http://twitter.com/statuses/public_timeline.json";
	
	url = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
														cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														timeoutInterval:60.0];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	buf = [[NSMutableData data] retain];
//*/
}

- (void)connection:(NSURLConnection *)aConn didReceiveResponse:(NSURLResponse *)response
{
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
	
	NSLog(@"Connection failed! Error - %@ %@",
				[error localizedDescription],
				[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	if (delegate && [delegate respondsToSelector:@selector(friendTimelineDownloaderDidFail:error:)]) {
		[delegate friendTimelineDownloaderDidFail:self error:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
	NSString* s = [[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding];
	
	//NSLog(s);
	
	NSArray* ary = [s JSONValue];
	NSMutableArray* messages = [NSMutableArray array];
	
	int i;
	for (i=[ary count]-1; i>=0; i--) {
		Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i]];
		[messages addObject:m];
	}
	
	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;
	
	if (delegate && [delegate respondsToSelector:@selector(friendTimelineDownloaderDidSucceed:messages:)]) {
		[delegate friendTimelineDownloaderDidSucceed:self messages:messages];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	if ([challenge previousFailureCount] == 0) {
		NSLog(@"trying auth");
		NSString* user = @"Psychs";
		NSString* pass = PASSWORD;
		NSURLCredential* cred = [NSURLCredential credentialWithUser:user password:pass persistence:NSURLCredentialPersistenceNone];
		[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
	} else {
		NSLog(@"failed auth");
		[[challenge sender] cancelAuthenticationChallenge:challenge];
	}
}

@end
