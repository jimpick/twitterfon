#import <UIKit/UIKit.h>
#import "Message.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*        message;
	UILabel*        nameLabel;
	UILabel*        textLabel;

    NSObject*       delegate;
    UIButton*       profileImage;
}

@property (nonatomic, assign) Message*  message;
@property (nonatomic, assign) UIButton* profileImage;


- (void)update:(id)delegate;

+ (UIImage*) linkButton;
+ (UIImage*) hilightedLinkButton;

@end
