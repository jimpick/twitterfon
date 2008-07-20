#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject
{
	NSObject*           delegate;
	NSMutableData*      buf;
	NSURLConnection*    conn;
}

@property (nonatomic, readonly) NSMutableData* buf;

- (ImageDownloader*)imageDownloaderWithDelegate:(id)aDelegate url:(NSString*)url;

@end
