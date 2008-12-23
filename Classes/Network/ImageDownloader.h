#import <UIKit/UIKit.h>
#import "TFConnection.h"

@interface ImageDownloader : TFConnection
{
    id      originalDelegate;
}

@property(nonatomic, assign) id originalDelegate;

@end
