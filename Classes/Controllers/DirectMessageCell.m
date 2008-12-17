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

- (void)prepareForReuse
{
    [super prepareForReuse];
    view.message.imageContainer = nil;
}

- (void)setMessage:(DirectMessage*)value
{
    value.imageContainer = self;
    view.message = value;
    self.contentView.backgroundColor = value.unread ? [UIColor cellColorForTab:TAB_MESSAGES] : [UIColor whiteColor];
    self.image = [[TwitterFonAppDelegate getAppDelegate].imageStore getProfileImage:value.senderProfileImageUrl delegate:value];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    view.frame = CGRectMake(48 + 20, 0, 320 - 48 - 20 - 10, 48 + 16 + 2);
    self.backgroundColor = self.contentView.backgroundColor;
    view.backgroundColor = self.contentView.backgroundColor;
}

- (void)dealloc {
    [super dealloc];
}


@end
