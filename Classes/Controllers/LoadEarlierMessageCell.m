//
//  LoadEarlierCell.m
//  TwitterFon
//
//  Created by kaz on 1/1/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import "LoadEarlierMessageCell.h"
#import "ColorUtils.h"

@implementation LoadEarlierMessageCell

- (id)initWithDelegate:(id)target {
    if (self = [super initWithFrame:CGRectZero reuseIdentifier:@"loadEarlierMessageCell"]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton* loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loadButton setTitle:@"Load Earlier Messages" forState:UIControlStateNormal];
        [loadButton setTitleColor:[UIColor cellLabelColor] forState:UIControlStateNormal];
        [loadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        loadButton.font = [UIFont boldSystemFontOfSize:15];

        UIImage *btnImage = [[UIImage imageNamed:@"EarlierButton.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
        [loadButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        
        UIImage *btnPressedImage = [[UIImage imageNamed:@"EalierButtonPressed.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:0];
        [loadButton setBackgroundImage:btnPressedImage forState:UIControlStateHighlighted];
        
        [loadButton addTarget:target action:@selector(loadEarlierMessages:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:loadButton];
        loadButton.frame = CGRectMake(10, 10, 300, 46);         
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [super dealloc];
}


@end
