#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"

@interface NSObject (MessageCellDelegate)
- (void)didTouchDetailButton:(id)sender;
@end

@interface MessageCell (Private)
- (void)didTouchAccessory:(id)sender;
@end

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
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    self.target = self;
    self.accessoryAction = @selector(didTouchAccessory:);
    
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
    self.accessoryType = message.accessoryType;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;	
    textLabel.frame = [textLabel textRectForBounds:message.textBounds limitedToNumberOfLines:10];
}

@end
