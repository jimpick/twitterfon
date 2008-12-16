#import <UIKit/UIKit.h>
#import "TweetCellBase.h"

@interface UserTimelineCell : TweetCellBase
{
    UIActivityIndicatorView*    spinner;
    BOOL                        inEditing;
}

@property (nonatomic, assign) BOOL inEditing;

- (void)update;

- (void)toggleFavorite:(BOOL)favorited;
- (void)toggleSpinner:(BOOL)flag;

@end
