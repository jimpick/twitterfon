#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "REString.h"
#import "TimeUtils.h"

@interface NSObject (MessageCellDelegate)
- (void)didTouchLinkButton:(NSString*)url;
- (void)didTouchProfileImage:(MessageCell*)cell;
@end

@interface MessageCell (Private)
- (void)didTouchAccessory:(id)sender;
- (void)didTouchProfileImage:(id)sender;
@end

static UIImage* sLinkButton = nil;
static UIImage* sHighlightedLinkButton = nil;

@implementation MessageCell

@synthesize message;
@synthesize profileImage;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];

    // name label
    nameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    nameLabel.backgroundColor = [UIColor whiteColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:14];
    nameLabel.textAlignment = UITextAlignmentLeft;
    nameLabel.frame = CGRectMake(LEFT, 0, CELL_WIDTH - DETAIL_BUTTON_WIDTH, TOP);
    [self.contentView addSubview:nameLabel];

    // text label
    textLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.textColor = [UIColor blackColor];
    textLabel.highlightedTextColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.numberOfLines = 10;
    textLabel.textAlignment = UITextAlignmentLeft;
    textLabel.contentMode = UIViewContentModeTopLeft;
    [self.contentView addSubview:textLabel];
      
    profileImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileImage addTarget:self action:@selector(didTouchProfileImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:profileImage];

    // timestamp   	   	 
    timestamp = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];  	  	 
    timestamp.backgroundColor = [UIColor whiteColor];  	  	 
    timestamp.textColor = [UIColor grayColor];  	  	 
    timestamp.highlightedTextColor = [UIColor whiteColor];  	  	 
    timestamp.font = [UIFont systemFontOfSize:12];  	  	 
    timestamp.textAlignment = UITextAlignmentLeft;//Right;  	  	 
    timestamp.frame = CGRectMake(TIMESTAMP_LEFT, 0, TIMESTAMP_WIDTH, TOP);  	  	 
    [self.contentView addSubview:timestamp];
    
    // linkButton
    linkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    linkButton.frame = CGRectMake(288, 0, 32, 32);
    [linkButton setImage:[MessageCell linkButtonImage] forState:UIControlStateNormal];
    [linkButton setImage:[MessageCell hilightedLinkButtonImage] forState:UIControlStateHighlighted];
    [linkButton addTarget:self action:@selector(didTouchLinkButton:) forControlEvents:UIControlEventTouchUpInside];

	return self;
}

- (void)dealloc
{
    // No need to release child contents except link button
    [linkButton release];
    [super dealloc];
}    

- (void)didTouchLinkButton:(id)sender
{
    if (delegate) {
        NSString *pat = @"(((http(s?))\\:\\/\\/)([0-9a-zA-Z\\-]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/([0-9a-zA-Z_#!:.?+=&%@~*\';,\\-\\/\\$])*)?)";
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        if ([message.text matches:pat withSubstring:array]) {
            [delegate didTouchLinkButton:[array objectAtIndex:0]];
        }
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
    delegate = aDelegate;
    type     = aType;
    nameLabel.text = message.user.screenName;
 	textLabel.text = message.text;

    if (type == MSG_TYPE_USER) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        timestamp.text      = message.timestamp;
        timestamp.hidden    = false;
        nameLabel.hidden    = true;
        profileImage.hidden = true;
        timestamp.frame     = CGRectMake(USER_CELL_PADDING, message.textBounds.size.height + 3, 280, 16);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        timestamp.hidden    = true;
        nameLabel.hidden    = false;
        profileImage.hidden = false;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    //
    // Added custom hyperlink button here.
    //
    if (message.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        self.accessoryView = linkButton;
    }
    else {
        self.accessoryView = nil;
        self.accessoryType = message.accessoryType;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;
    textLabel.backgroundColor = self.contentView.backgroundColor;
    nameLabel.backgroundColor = self.contentView.backgroundColor;
    textLabel.frame = message.textBounds;
    profileImage.frame = CGRectMake(IMAGE_PADDING, 0, IMAGE_WIDTH, message.cellHeight);
}

+ (UIImage*) linkButtonImage
{
    if (sLinkButton == nil) {
        sLinkButton = [[UIImage imageNamed:@"link.png"] retain];
    }
    return sLinkButton;
}

+ (UIImage*) hilightedLinkButtonImage
{
    if (sHighlightedLinkButton == nil) {
        sHighlightedLinkButton = [[UIImage imageNamed:@"link_highlighted.png"] retain];
    }
    return sHighlightedLinkButton;
}

@end
