#import <UIKit/UIKit.h>
#import "MessageCellBase.h"

@interface UserMessageCell : MessageCellBase
{
    UIActivityIndicatorView*    spinner;
    BOOL                        inEditing;
}

@property (nonatomic, assign) BOOL inEditing;

- (void)update;

- (void)toggleFavorite:(BOOL)favorited;
- (void)toggleSpinner:(BOOL)flag;

@end
