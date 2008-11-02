#import <UIKit/UIKit.h>
#import "Message.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*        message;
	UILabel*        nameLabel;
	UILabel*        textLabel;
    UILabel*        timestamp;

    NSObject*       delegate;
    UIButton*       profileImage;
    MessageType     type;
    
    BOOL            inEditing;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;
@property (nonatomic, assign) BOOL inEditing;

- (void)update:(MessageType)type delegate:(id)delegate;

+ (UIImage*) favoriteImage;
+ (UIImage*) favoritedImage;

@end
