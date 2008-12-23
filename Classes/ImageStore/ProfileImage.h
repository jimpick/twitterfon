#import <UIKit/UIKit.h>
#import "User.h"
#import "ImageDownloader.h"

@class ImageStore;

@interface ProfileImage : NSObject
{
	UIImage*            image;
    NSString*           url;
    ImageStore*         store;
    ImageDownloader*    downloader;
}

@property(nonatomic, readonly) UIImage* image;
@property(nonatomic, copy) NSString* url;
@property(nonatomic, readonly) ImageDownloader* downloader;

- (ProfileImage*)initWithURL:(NSString*)url imageStore:(ImageStore*)store;
- (void)requestImage;

@end
