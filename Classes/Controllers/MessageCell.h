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
    UIButton*       linkButton;
    MessageType     type;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;

- (void)update:(MessageType)type delegate:(id)delegate;

+ (UIImage*) linkButtonImage;
+ (UIImage*) hilightedLinkButtonImage;

@end
