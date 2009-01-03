//
//  DMDetailCell.h
//  TwitterFon
//
//  Created by kaz on 1/2/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectMessage.h"
#import "DMDetailCellView.h"

@interface DMDetailCell : UITableViewCell {
    DMDetailCellView*   cellView;
    CGFloat             cellHeight;
}

@property(nonatomic, assign) CGFloat cellHeight;

- (id)initWithMessage:(DirectMessage*)value;

@end
