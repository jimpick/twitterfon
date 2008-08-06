#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"

@interface NSObject (MessageCellDelegate)
- (void)didTouchDetailButton:(id)sender;
@end

@interface MessageCell (Private)
- (void)didTouchAccessory:(id)sender;
@end

static UIImage* sLinkButton = nil;
static UIImage* sHighlightedLinkButton = nil;

@implementation MessageCell

@synthesize message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    
    // name label
    nameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.highlightedTextColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:14];
    nameLabel.textAlignment = UITextAlignmentLeft;
    nameLabel.frame = CGRectMake(LEFT, 0, CELL_WIDTH - DETAIL_BUTTON_WIDTH, 16);
    
    [self.contentView addSubview:nameLabel];
		
    // text label
    textLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor blackColor];
    textLabel.highlightedTextColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.numberOfLines = 10;
    textLabel.textAlignment = UITextAlignmentLeft;
    textLabel.contentMode = UIViewContentModeTopLeft;
    [self.contentView addSubview:textLabel];
    
	return self;
}

- (void)didTouchAccessory:(id)sender
{
    if (delegate) {
        [delegate didTouchDetailButton:self];
    }
}

- (void)update:(id)aDelegate
{
    delegate = aDelegate;
	nameLabel.text = message.user.screenName;
	textLabel.text = [message.text unescapeHTML];
    //
    // Added custom hyperlink button here.
    //
    if (message.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(288, 0, 32, 32);
        [button setImage:[MessageCell linkButton] forState:UIControlStateNormal];
        [button setImage:[MessageCell hilightedLinkButton] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(didTouchAccessory:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = button;
    }
    else {
        self.accessoryView = nil;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;	
    textLabel.frame = [textLabel textRectForBounds:message.textBounds limitedToNumberOfLines:10];
}

+ (UIImage*) linkButton
{
    if (sLinkButton == nil) {
        sLinkButton = [[UIImage imageNamed:@"link.png"] retain];
    }
    return sLinkButton;
}

+ (UIImage*) hilightedLinkButton
{
    if (sHighlightedLinkButton == nil) {
        sHighlightedLinkButton = [[UIImage imageNamed:@"link_highlighted.png"] retain];
    }
    return sHighlightedLinkButton;
}

@end
