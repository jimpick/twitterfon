#import <UIKit/UIKit.h>
#import "Message.h"
#import "TweetCellView.h"

#define MESSAGE_REUSE_INDICATOR @"TweetCell"

@interface TweetCellBase : UITableViewCell
{
	Message*        message;
    TweetCellView*  cellView;
    UIButton*       imageButton;
}

@property (nonatomic, assign) Message*  message;

@end
