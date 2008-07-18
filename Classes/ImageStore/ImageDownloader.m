#import "ImageDownloader.h"

@interface NSObject (ImageDownloaderDelegate)
- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender;
- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error;
@end


@implementation ImageDownloader

@synthesize image;
@synthesize url;

- (id)initWithDelegate:(id)aDelegate;
{
	self = [super init];
	delegate = aDelegate;
	return self;
}

- (void)dealloc
{
	[url release];
	[buf release];
	[image release];
	[conn release];
	[super dealloc];
}

- (void)start:(NSString*)anUrl
{
	[url autorelease];
	[conn autorelease];
	[buf autorelease];
	
	url = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)anUrl, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
	NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
																	    cachePolicy:NSURLRequestUseProtocolCachePolicy
																	    timeoutInterval:60.0];
	conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	buf = [[NSMutableData data] retain];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (ImageDownloader*)imageDownloaderWithDelegate:(id)aDelegate url:(NSString*)url
{
	ImageDownloader* d = [[[ImageDownloader alloc] initWithDelegate:aDelegate] autorelease];
	[d start:url];
	return d;
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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[image release];
	image = [[UIImage imageWithData:buf] retain] ;

	[conn autorelease];
	conn = nil;
	[buf autorelease];
	buf = nil;
	
	if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidSucceed:)]) {
		[delegate imageDownloaderDidSucceed:self];
	}
}

@end
