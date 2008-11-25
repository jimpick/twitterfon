#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageCellView.h"
#import "ProfileImageButton.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*            message;
    MessageCellView*    cellView;
    ProfileImageButton* profileImage;

    UIActivityIndicatorView*    spinner;
    
    NSObject*           delegate;
    MessageType         type;
    
    BOOL            inEditing;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) ProfileImageButton* profileImage;
@property (nonatomic, assign) BOOL inEditing;

- (void)update:(MessageType)type delegate:(id)delegate;

- (void)toggleSpinner:(BOOL)flag;

+ (UIImage*) favoriteImage;
+ (UIImage*) favoritedImage;

@end
