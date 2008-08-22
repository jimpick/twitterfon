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
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;

- (void)update:(MessageType)type delegate:(id)delegate;

+ (UIImage*) linkButton;
+ (UIImage*) hilightedLinkButton;

@end
