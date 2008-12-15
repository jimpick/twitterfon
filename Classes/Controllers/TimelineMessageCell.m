#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "TimelineMessageCell.h"
#import "ColorUtils.h"

@implementation TimelineMessageCell

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
    if (message.type == MSG_TYPE_MESSAGES || message.type == MSG_TYPE_SENT) {
        [postView editDirectMessage:message.user.screenName];
    }
    else {
        [postView inReplyTo:message];
    }
}

- (void)update
{
    cellView.message    = message;
    
    message.user.imageContainer = self;
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [imageButton setImage:[appDelegate.imageStore getProfileImage:message.user isLarge:false] forState:UIControlStateNormal];
    
    self.contentView.backgroundColor = (message.unread) ? [UIColor cellColorForTab:message.type] : [UIColor whiteColor];

    if (message.hasReply) {
        if (message.type == MSG_TYPE_FRIENDS || message.type == MSG_TYPE_SEARCH_RESULT) {
            self.contentView.backgroundColor = [UIColor cellColorForTab:TAB_REPLIES];
        }
    }
    
    self.accessoryType = message.accessoryType;
    cellView.frame = CGRectMake(LEFT, 0, CELL_WIDTH, message.cellHeight - 1);
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    self.backgroundColor = self.contentView.backgroundColor;
    cellView.backgroundColor = self.contentView.backgroundColor;
    
    imageButton.frame = CGRectMake(IMAGE_PADDING, (message.cellHeight - 48 - 1)/2, IMAGE_WIDTH, 48);
}

@end
