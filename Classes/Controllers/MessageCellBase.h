#import <UIKit/UIKit.h>
#import "Message.h"
#import "MessageCellView.h"

#define MESSAGE_REUSE_INDICATOR @"MessageCell"

@interface MessageCellBase : UITableViewCell
{
	Message*            message;
    MessageCellView*    cellView;
    UIButton*           imageButton;
}

@property (nonatomic, assign) Message*  message;

@end
