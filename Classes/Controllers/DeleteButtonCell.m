//
//  deleteButtonCell.m
//  TwitterFon
//
//  Created by kaz on 12/12/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "DeleteButtonCell.h"


@implementation DeleteButtonCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        UIImage *image = [UIImage imageNamed:@"deleteButton.png"];
        UIImageView *background = [[[UIImageView alloc] initWithImage:[image stretchableImageWithLeftCapWidth:7 topCapHeight:0]] autorelease];
        
        UIImage *imagePressed = [UIImage imageNamed:@"deleteButton_pressed.png"];
        UIImageView *backgroundPressed = [[[UIImageView alloc] initWithImage:[imagePressed stretchableImageWithLeftCapWidth:7 topCapHeight:0]] autorelease];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        [self.contentView addSubview:label];

        self.backgroundView = background;
        self.selectedBackgroundView = backgroundPressed;
    }
    return self;
}

- (void)setTitle:(NSString*)title
{
    label.text = title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)dealloc {
    [super dealloc];
}


@end
