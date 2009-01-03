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
    [appDelegate toggleFavorite:status];
}

- (void)update
{
    cellView.status = status;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.accessoryType = status.accessoryType;
    
    self.selectionStyle = (status.cellType == TWEET_CELL_TYPE_DETAIL) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;

    self.contentView.backgroundColor = [UIColor whiteColor];
    cellView.frame = CGRectMake(USER_CELL_LEFT, 0, USER_CELL_WIDTH, status.cellHeight - 1);
        
    if (status.favorited) {
        [imageButton setImage:[UserTimelineCell favoritedImage] forState:UIControlStateNormal];
    }
    else {
        [imageButton setImage:[UserTimelineCell favoriteImage] forState:UIControlStateNormal];
    }
    
    if (inEditing) {
        cellView.frame = CGRectOffset(cellView.frame, -32, 0);
        imageButton.hidden = true;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    imageButton.frame = CGRectMake(2, 0, 38, status.cellHeight);
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
        spinner.frame = CGRectMake(11, (status.cellHeight - 20)/2, 20, 20);
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
