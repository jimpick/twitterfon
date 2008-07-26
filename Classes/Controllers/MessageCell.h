#import <UIKit/UIKit.h>
#import "Message.h"
#import "ProfileImageButton.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*        message;
	UILabel*        nameLabel;
	UILabel*        textLabel;

    ProfileImageButton* imageView;
}

@property (nonatomic, assign) Message*              message;
@property (nonatomic, assign) ProfileImageButton*   imageView;

- (void)update;

@end
