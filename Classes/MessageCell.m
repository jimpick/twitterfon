#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"

@implementation MessageCell

@synthesize message;
@synthesize imageView;

#define IMAGE_PADDING   10
#define H_MARGIN        10
#define INDICATOR_WIDTH 23
#define IMAGE_WIDTH     48

#define TOP             16
#define LEFT            (IMAGE_PADDING * 2 + IMAGE_WIDTH)

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
    
    imageView = [[[ProfileImageButton alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:imageView];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return self;
}

- (void)update
{
	nameLabel.text = message.user.screenName;
	textLabel.text = [message.text unescapeHTML];  
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    CGRect rc = self.contentView.bounds;
    CGRect bounds;

    NSRange r = [textLabel.text rangeOfString:@"http://"];
    if (r.location != NSNotFound) {    
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.backgroundColor = self.contentView.backgroundColor;
    imageView.frame = CGRectMake(IMAGE_PADDING, 0, IMAGE_WIDTH, rc.size.height);
    
    int contentWidth = 320 - INDICATOR_WIDTH - LEFT;
    nameLabel.frame = CGRectMake(LEFT,   0, contentWidth, 16);
    bounds          = CGRectMake(LEFT, TOP, contentWidth, rc.size.height - TOP);
    textLabel.frame = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
}

+ (CGFloat)heightForCell:(NSString*)text
{
    CGRect bounds;
    CGRect result;
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectZero];

    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.numberOfLines = 10;
    
    textLabel.text = text;
    bounds = CGRectMake(0, 0, 320 - INDICATOR_WIDTH - LEFT, 200);
    result = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
    result.size.height += 18;
    if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    [textLabel release];
return result.size.height;

}

@end
