#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageCellView.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*            message;
    MessageCellView*    cellView;
    UIButton*           profileImage;
    
    NSObject*           delegate;
    MessageType         type;
    
    BOOL            inEditing;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;
@property (nonatomic, assign) BOOL inEditing;

- (void)update:(MessageType)type delegate:(id)delegate;

+ (UIImage*) favoriteImage;
+ (UIImage*) favoritedImage;

@end
