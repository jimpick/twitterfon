#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageCellView.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*            message;
    MessageCellView*    cellView;
    UIButton*           profileImage;

    UIActivityIndicatorView*    spinner;
    
    NSObject*           delegate;
    MessageCellType     cellType;
    
    BOOL            inEditing;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;
@property (nonatomic, assign) BOOL      inEditing;

- (void)update:(MessageCellType)type delegate:(id)delegate;

- (void)toggleFavorite:(BOOL)favorited;
- (void)toggleSpinner:(BOOL)flag;

+ (UIImage*) favoriteImage;
+ (UIImage*) favoritedImage;

@end
