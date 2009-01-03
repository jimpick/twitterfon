//
//  DMDetailCellView.h
//  TwitterFon
//
//  Created by kaz on 1/2/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectMessage.h"

@interface DMDetailCellView : UIView {
    DirectMessage*  message;
    CGRect          textBounds;
}

- (CGFloat)setMessage:(DirectMessage*)message;

@end
