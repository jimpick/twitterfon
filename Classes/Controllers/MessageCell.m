#import <QuartzCore/QuartzCore.h>
#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "REString.h"
#import "TimeUtils.h"

@interface NSObject (MessageCellDelegate)
- (void)didTouchLinkButton:(Message*)message links:(NSArray*)links;
- (void)didTouchProfileImage:(MessageCell*)cell;
@end

@interface MessageCell (Private)
- (void)didTouchAccessory:(id)sender;
- (void)didTouchProfileImage:(id)sender;
@end

static UIImage* sFavorite = nil;
static UIImage* sFavorited = nil;

@implementation MessageCell

@synthesize message;
@synthesize profileImage;
@synthesize inEditing;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];

    cellView = [[[MessageCellView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:cellView];
    
    profileImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileImage addTarget:self action:@selector(didTouchProfileImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:profileImage];

    inEditing = false;

    self.target = self;
    self.accessoryAction = @selector(didTouchLinkButton:);
    
	return self;
}

- (void)dealloc
{
    [super dealloc];
}    

static NSString *urlRegexp  = @"(((http(s?))\\:\\/\\/)([0-9a-zA-Z\\-]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/([0-9a-zA-Z_#!:.?+=&%@~*\';,\\-\\/\\$])*)?)";
static NSString *nameRegexp = @"(@[0-9a-zA-Z_]+)";

- (void)didTouchLinkButton:(id)sender
{
    NSMutableArray *links = [NSMutableArray array];

    NSMutableArray *array = [NSMutableArray array];
    NSString *tmp = message.text;
    
    while ([tmp matches:urlRegexp withSubstring:array]) {
        NSString *url = [array objectAtIndex:0];
        [links addObject:url];
        NSRange r = [tmp rangeOfString:url];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }
    
    tmp = message.text;
    while ([tmp matches:nameRegexp withSubstring:array]) {
        NSString *username = [array objectAtIndex:0];
        [links addObject:username];
        NSRange r = [tmp rangeOfString:username];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }
          
    if (delegate) {
        [delegate didTouchLinkButton:message links:links];
    }
}

- (void)didTouchProfileImage:(id)sender
{
    if (delegate) {
        [delegate didTouchProfileImage:self];
    }
}

- (void)update:(MessageType)aType delegate:(id)aDelegate
{
    delegate            = aDelegate;
    type                = aType;
    cellView.message    = message;

    self.selectionStyle = (type == MSG_TYPE_USER) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    self.accessoryType = message.accessoryType;

    if (type == MSG_TYPE_USER) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        cellView.frame = CGRectMake(USER_CELL_LEFT, 0, USER_CELL_WIDTH, message.cellHeight - 1);
    }
    else {
        cellView.frame = CGRectMake(LEFT, 0, CELL_WIDTH, message.cellHeight - 1);
    }
    
    if (type == MSG_TYPE_USER && inEditing) {
        cellView.frame = CGRectOffset(cellView.frame, -32, 0);
        profileImage.hidden = true;
    }
    else {
        profileImage.hidden = false;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    self.backgroundColor = self.contentView.backgroundColor;
    cellView.backgroundColor = self.contentView.backgroundColor;
    
    if (message.type == MSG_TYPE_USER) {
        profileImage.frame = CGRectMake(2, 0, 38, message.cellHeight);
    }
    else {
        profileImage.frame = CGRectMake(IMAGE_PADDING, 0, IMAGE_WIDTH, message.cellHeight);
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (type == MSG_TYPE_USER && animated && (editing || inEditing)) {
#if 0
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionFade];
        [animation setDuration:0.3];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [profileImage.layer addAnimation:animation forKey:@"favoriteButton"];
#endif
        profileImage.hidden = editing;
        
        [UIView beginAnimations:nil context:nil];

        int x = (editing) ? 10 : 42;
        cellView.frame = CGRectMake(x, cellView.frame.origin.y, cellView.frame.size.width, cellView.frame.size.height);
        [UIView commitAnimations];
        
        inEditing = editing;
    }

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
        profileImage.hidden = true;
    }
    else {
        [spinner stopAnimating];
        profileImage.hidden = false;
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
