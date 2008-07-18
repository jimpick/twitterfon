#import <UIKit/UIKit.h>

@interface TimelineDownloader : NSObject
{
	NSObject*           delegate;
	NSURLConnection*    conn;
	NSMutableData*      buf;
    int                 status;
    NSString*           method;
}

@property (nonatomic, readonly) BOOL active;

- (id)initWithDelegate:(NSObject*)delegate;
- (void)showDialog:(NSString*)title withMessage:(NSString*)msg;
- (void)get:(NSString*)method;

@end
