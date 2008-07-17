#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject
{
	NSObject* delegate;
	NSString* url;
	NSMutableData* buf;
	UIImage* image;
	NSURLConnection* conn;
}

@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) NSString* url;

+ (ImageDownloader*)imageDownloaderWithDelegate:(id)aDelegate url:(NSString*)url;

@end
