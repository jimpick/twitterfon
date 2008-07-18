#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageCell : UITableViewCell
{
	Message*     message;
	UILabel*     nameLabel;
	UILabel*     textLabel;
}

@property (nonatomic, assign) Message* message;

- (void)update;

@end
