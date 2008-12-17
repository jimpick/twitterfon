#import <UIKit/UIKit.h>
#import "Status.h"
#import "TweetCellView.h"

#define MESSAGE_REUSE_INDICATOR @"TweetCell"

@interface TweetCellBase : UITableViewCell
{
	Status*         status;
    TweetCellView*  cellView;
    UIButton*       imageButton;
}

@property (nonatomic, assign) Status*  status;

@end
