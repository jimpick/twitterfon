//
//  DMDetailCell.m
//  TwitterFon
//
//  Created by kaz on 1/2/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "DMDetailCell.h"
#import "Status.h"

@implementation DMDetailCell

@synthesize cellHeight;

- (id)initWithMessage:(DirectMessage*)value
{
    self = [super initWithFrame:CGRectZero reuseIdentifier:@"DMDetailCell"];

    message = value;
        
    messageLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.text = value.text;
    messageLabel.numberOfLines = 20;
    
    CGRect bounds = CGRectMake(10, 5, 280, 120);
    if (message.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        bounds.size.width -= DETAIL_BUTTON_WIDTH;
        self.accessoryType = message.accessoryType;
    }
    
    CGRect r = [messageLabel textRectForBounds:bounds limitedToNumberOfLines:20];
    messageLabel.frame = r;
    [self.contentView addSubview:messageLabel];
    
    cellHeight = messageLabel.frame.size.height + 10;
    if (cellHeight < 44) {
        cellHeight = 44;
        r.origin.y = floor((cellHeight - messageLabel.frame.size.height) / 2);
        messageLabel.frame = r;
    }
    
    self.target = self;
    self.accessoryAction = @selector(didTouchLinkButton:);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    return self;
}

- (void)didTouchLinkButton:(id)sender
{
    [[TwitterFonAppDelegate getAppDelegate] openLinksViewController:message.text];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}


@end
