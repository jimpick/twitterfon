//
//  DirectMessageCell.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DirectMessageCell.h"
#import "TwitterFonAppDelegate.h"
#import "ColorUtils.h"

@implementation DirectMessageCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        view = [[DirectMessageCellView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:view];
        self.contentView.backgroundColor = [UIColor whiteColor];
        [view release];
    }
    return self;
}

- (void)updateImage:(UIImage*)image
{
    self.image = image;
    [self layoutSubviews];
}

- (void)setMessage:(DirectMessage*)value
{
    view.message = value;
    self.contentView.backgroundColor = value.unread ? [UIColor cellColorForTab:TAB_MESSAGES] : [UIColor whiteColor];
    self.image = [self getProfileImage:value.sender.profileImageUrl isLarge:false];
    
    view.frame = CGRectMake(48 + 20, 0, 320 - 48 - 20 - 10, view.message.cellHeight - 1);
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = self.contentView.backgroundColor;
    view.backgroundColor = self.contentView.backgroundColor;
}

- (void)dealloc {
    [super dealloc];
}


@end
