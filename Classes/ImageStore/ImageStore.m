#import "ImageStore.h"
#import "ImageDownloader.h"

@interface NSObject (ImageStoreDelegate)
- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url;
@end


@interface ImageStore (Private)
- (void)sendRequestForImage:(NSString*)url;
@end

@implementation ImageStore

- (id)init
{
	self = [super init];
	images = [[NSMutableDictionary dictionary] retain];
	conns = [[NSMutableDictionary dictionary] retain];
	return self;
}

- (void)dealloc
{
	[images release];
	[conns release];
	[super dealloc];
}

- (UIImage*)getImage:(NSString*)url
{
	UIImage* image = [images objectForKey:url];
	if (!image && ![conns objectForKey:url]) {
		[self sendRequestForImage:url];
	}
	return image;
}

- (void)sendRequestForImage:(NSString*)url
{
	ImageDownloader* d = [ImageDownloader imageDownloaderWithDelegate:self url:url];
	[conns setObject:d forKey:url];
}

- (void)imageDownloaderDidSucceed:(ImageDownloader*)sender
{
	NSString* url = [[sender.url retain] autorelease];
	
	UIImage* image = sender.image;
	if (image) [images setObject:image forKey:url];
	[conns removeObjectForKey:url];
	if (delegate && [delegate respondsToSelector:@selector(imageStoreDidGetNewImage:url:)]) {
		[delegate imageStoreDidGetNewImage:self url:url];
	}
}

- (void)imageDownloaderDidFail:(ImageDownloader*)sender error:(NSError*)error
{
	[conns removeObjectForKey:sender.url];
}

@end
