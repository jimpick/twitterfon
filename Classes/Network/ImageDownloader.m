#import "ImageDownloader.h"

@interface NSObject (ImageDownloaderDelegate)
- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender;
- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error;
@end


@implementation ImageDownloader

- (void)dealloc
{
	[super dealloc];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* res = (NSHTTPURLResponse*)response;
    if (res) {
        statusCode = res.statusCode;
    }
	[buf setLength:0];
}

- (void)TFConnectionDidFailWithError:(NSError*)error
{
	if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidFail:error:)]) {
		[delegate imageDownloaderDidFail:self error:error];
	}
    [self autorelease];
}   

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    if (statusCode == 200) {
        if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidSucceed:)]) {
            [delegate imageDownloaderDidSucceed:self];
        }
    }
    [self autorelease];
}

@end
