#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"

@implementation MessageCell

@synthesize message;
@synthesize imageView;

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
    nameLabel.frame = CGRectMake(LEFT, 0, CELL_WIDTH, 16);
    
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
    
    imageView = [[[ProfileImageButton alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:imageView];

	return self;
}

- (void)update
{
	nameLabel.text = message.user.screenName;
	textLabel.text = [message.text unescapeHTML];  
    self.accessoryType = message.accessoryType;
    if (self.accessoryType == UITableViewCellAccessoryNone) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;	
    imageView.frame = CGRectMake(IMAGE_PADDING, 0, IMAGE_WIDTH, message.cellHeight);
    textLabel.frame = [textLabel textRectForBounds:message.textBounds limitedToNumberOfLines:10];
}

@end
