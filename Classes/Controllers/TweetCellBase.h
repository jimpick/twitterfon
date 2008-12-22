#import <UIKit/UIKit.h>
#import "Status.h"
#import "TweetCellView.h"
#import "ProfileImageCell.h"

#define MESSAGE_REUSE_INDICATOR @"TweetCell"

@interface TweetCellBase : ProfileImageCell
{
	Status*         status;
    TweetCellView*  cellView;
    UIButton*       imageButton;
}

@property (nonatomic, assign) Status*  status;

@end
