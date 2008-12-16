#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "UserTimelineCell.h"

static UIImage* sFavorite = nil;
static UIImage* sFavorited = nil;

@interface UserTimelineCell(Private)
+ (UIImage*) favoriteImage;
+ (UIImage*) favoritedImage;
@end

@implementation UserTimelineCell

@synthesize inEditing;

- (void)dealloc
{
    [super dealloc];
}    

- (void)didTouchImageButton:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [self toggleSpinner:true];
    [appDelegate toggleFavorite:message];
}

- (void)update
{
    cellView.message = message;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.accessoryType = message.accessoryType;
    
    self.selectionStyle = (message.cellType == MSG_CELL_TYPE_DETAIL) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;

    self.contentView.backgroundColor = [UIColor whiteColor];
    cellView.frame = CGRectMake(USER_CELL_LEFT, 0, USER_CELL_WIDTH, message.cellHeight - 1);
        
    if (message.favorited) {
        [imageButton setImage:[UserTimelineCell favoritedImage] forState:UIControlStateNormal];
    }
    else {
        [imageButton setImage:[UserTimelineCell favoriteImage] forState:UIControlStateNormal];
    }
    
    if (message.type == MSG_TYPE_MESSAGES || message.type == MSG_TYPE_SENT) {
        cellView.frame = CGRectOffset(cellView.frame, -32, 0);
        imageButton.hidden = true;
    }

    if (inEditing) {
        cellView.frame = CGRectOffset(cellView.frame, -32, 0);
        imageButton.hidden = true;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    imageButton.frame = CGRectMake(2, 0, 38, message.cellHeight);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (animated && (editing || inEditing)) {

        imageButton.hidden = editing;
        [UIView beginAnimations:nil context:nil];
        int x = (editing) ? 10 : 42;
        cellView.frame = CGRectMake(x, cellView.frame.origin.y, cellView.frame.size.width, cellView.frame.size.height);
        [UIView commitAnimations];
        
        inEditing = editing;
    }

}

- (void)toggleFavorite:(BOOL)favorited
{
    if (favorited) {
        [imageButton setImage:[UserTimelineCell favoritedImage] forState:UIControlStateNormal];
    }
    else {
        [imageButton setImage:[UserTimelineCell favoriteImage] forState:UIControlStateNormal];
    }    
    
    [self toggleSpinner:false];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.2];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [imageButton.layer addAnimation:animation forKey:@"favoriteButton"];
}

- (void)toggleSpinner:(BOOL)animation
{
    if (spinner == nil) {
        spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        spinner.frame = CGRectMake(11, (message.cellHeight - 20)/2, 20, 20);
        spinner.hidesWhenStopped = YES;
        [self.contentView addSubview:spinner];
    }

    if (animation) {
        [spinner startAnimating];
        imageButton.hidden = true;
    }
    else {
        [spinner stopAnimating];
        imageButton.hidden = false;
    }
}

+ (UIImage*) favoriteImage
{
    if (sFavorite == nil) {
        sFavorite = [[UIImage imageNamed:@"favorite.png"] retain];
    }
    return sFavorite;
}

+ (UIImage*) favoritedImage
{
    if (sFavorited == nil) {
        sFavorited = [[UIImage imageNamed:@"favorited.png"] retain];
    }
    return sFavorited;
}

@end
