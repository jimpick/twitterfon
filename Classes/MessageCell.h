#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageCell : UITableViewCell
{
	Message*     message;
	UILabel*     nameLabel;
	UILabel*     textLabel;
    UIImageView* imageView;
}

@property (nonatomic, assign) Message* message;
@property (nonatomic, assign) UIImageView *imageView;

- (void)update;

@end
