#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "MessageCellBase.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "REString.h"
#import "TimeUtils.h"

@implementation MessageCellBase

@synthesize message;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];

    cellView = [[[MessageCellView alloc] initWithFrame:CGRectZero] autorelease];
    [self.contentView addSubview:cellView];
    
    imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageButton addTarget:self action:@selector(didTouchImageButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:imageButton];
    
    self.target = self;
    self.accessoryAction = @selector(didTouchLinkButton:);
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
	return self;
}

- (void)dealloc
{
    [super dealloc];
}    

- (void)didTouchImageButton:(id)sender
{
    // do nothing here
}

- (void)didTouchLinkButton:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openLinksViewController:message];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    self.backgroundColor = self.contentView.backgroundColor;
    cellView.backgroundColor = self.contentView.backgroundColor;
}

@end
