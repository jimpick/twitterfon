//
//  DMDetailCell.m
//  TwitterFon
//
//  Created by kaz on 1/2/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "DMDetailCell.h"

@implementation DMDetailCell

@synthesize cellHeight;

- (id)initWithMessage:(DirectMessage*)message
{
    self = [super initWithFrame:CGRectZero reuseIdentifier:@"DMDetailCell"];

    cellView = [[[DMDetailCellView alloc] initWithFrame:CGRectZero] autorelease];
    cellHeight = [cellView setMessage:message];
    [self.contentView addSubview:cellView];
        
    if (message.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        self.accessoryType = message.accessoryType;
    }
    
    self.target = cellView;
    self.accessoryAction = @selector(didTouchLinkButton:);
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}


@end
