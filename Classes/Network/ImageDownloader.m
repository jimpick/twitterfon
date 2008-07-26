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

- (void)TFConnectionDidFailWithError:(NSError*)error
{
    [delegate imageDownloaderDidFail:self error:error];
    [self autorelease];
}   

- (void)TFConnectionDidFinishLoading:(NSString*)content
{
    if (statusCode == 200) {
        [delegate imageDownloaderDidSucceed:self];
    }
    [self autorelease];
}

@end
