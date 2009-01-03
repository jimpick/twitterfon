#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "TimelineCell.h"
#import "ColorUtils.h"

@implementation TimelineCell

- (void)dealloc
{
    [super dealloc];
}    

- (void)updateImage:(UIImage*)image
{
    [imageButton setImage:image forState:UIControlStateNormal];
    [imageButton setNeedsDisplay];
}

- (void)didTouchImageButton:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    
    PostViewController* postView = appDelegate.postView;
    [postView inReplyTo:status];
}

- (void)update
{
    cellView.status = status;
    [imageButton setImage:[self getProfileImage:status.user.profileImageUrl isLarge:false]
                 forState:UIControlStateNormal];
    
    self.contentView.backgroundColor = (status.unread) ? [UIColor cellColorForTab:status.type] : [UIColor whiteColor];

    if (status.hasReply) {
        if (status.type == TWEET_TYPE_FRIENDS || status.type == TWEET_TYPE_SEARCH_RESULT) {
            self.contentView.backgroundColor = [UIColor cellColorForTab:TAB_REPLIES];
        }
    }
    
    self.accessoryType = status.accessoryType;
    cellView.frame = CGRectMake(LEFT, 0, CELL_WIDTH, status.cellHeight - 1);
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    self.backgroundColor = self.contentView.backgroundColor;
    cellView.backgroundColor = self.contentView.backgroundColor;
    
    imageButton.frame = CGRectMake(IMAGE_PADDING, (status.cellHeight - 48 - 1)/2, IMAGE_WIDTH, 48);
}

@end
