#import <UIKit/UIKit.h>
#import "Message.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCell : UITableViewCell
{
	Message*        message;
	UILabel*        nameLabel;
	UILabel*        textLabel;
    NSObject*       delegate;
}

@property (nonatomic, assign) Message*              message;

- (void)update:(id)delegate;

@end
