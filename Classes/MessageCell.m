#import "MessageCell.h"

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

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return self;
}

- (void)update
{
	nameLabel.text = message.user.screenName;
	textLabel.text = message.text;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    CGRect rc = self.contentView.bounds;
    CGRect bounds;

    const int TOP = 16;
    const int LEFT = 68;
    const int HMARGIN = 10;
    const int VMARGIN = 0;
		
    nameLabel.frame = CGRectMake(LEFT, VMARGIN, rc.size.width - LEFT - HMARGIN, 16);
    bounds = CGRectMake(LEFT, TOP, rc.size.width - LEFT - HMARGIN, rc.size.height - TOP);
    textLabel.frame = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
}

@end
