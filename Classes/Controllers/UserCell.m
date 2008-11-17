//
//  UserCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

@synthesize userView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    userView = [[[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 146)] autorelease];
    [self.contentView addSubview:userView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
