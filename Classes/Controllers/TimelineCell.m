#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "TimelineCell.h"
#import "ColorUtils.h"

@implementation TimelineCell

- (void)dealloc
{
    status.user.imageContainer = nil;    
    [super dealloc];
}    

- (void)updateImage:(UIImage*)image
{
    [imageButton setImage:image forState:UIControlStateNormal];
    [imageButton setNeedsDisplay];
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    status.user.imageContainer = nil;
}


- (void)didTouchImageButton:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    
    PostViewController* postView = appDelegate.postView;
    if (status.type == TWEET_TYPE_MESSAGES || status.type == TWEET_TYPE_SENT) {
        [postView editDirectMessage:status.user.screenName];
    }
    else {
        [postView inReplyTo:status];
    }
}

- (void)update
{
    cellView.status = status;
    
    status.user.imageContainer = self;
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [imageButton setImage:[appDelegate.imageStore getProfileImage:status.user isLarge:false] forState:UIControlStateNormal];
    
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
