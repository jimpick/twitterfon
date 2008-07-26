#import "ImageDownloader.h"

@interface NSObject (ImageDownloaderDelegate)
- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender;
- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error;
@end


@implementation ImageDownloader

@synthesize buf;

- (void)dealloc
{
	[buf release];
	[conn release];
	[super dealloc];
}

- (ImageDownloader*)imageDownloaderWithDelegate:(id)aDelegate url:(NSString*)anUrl
{
    self = [super init];
    delegate = aDelegate;
    
	NSLog(@"Get image from %@", anUrl);
    
    NSString *url = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)anUrl, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [url autorelease];
	NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:60.0];
	buf  = [[NSMutableData data] retain];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;    
    
	return self;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;
	
	NSLog(@"Connection failed! Error - %@ %@",
				[error localizedDescription],
				[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidFail:error:)]) {
		[delegate imageDownloaderDidFail:self error:error];
	}
    [self autorelease];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidSucceed:)]) {
		[delegate imageDownloaderDidSucceed:self];
	}
	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;
    [self autorelease];
}

@end
