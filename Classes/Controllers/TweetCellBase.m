#import <QuartzCore/QuartzCore.h>
#import "TwitterFonAppDelegate.h"
#import "TweetCellBase.h"

@implementation TweetCellBase

@synthesize status;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];

    cellView = [[[TweetCellView alloc] initWithFrame:CGRectZero] autorelease];
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
    [appDelegate openLinksViewController:status];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

    self.backgroundColor = self.contentView.backgroundColor;
    cellView.backgroundColor = self.contentView.backgroundColor;
}

@end
