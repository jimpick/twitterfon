//
//  DirectMessageCellView.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectMessage.h"

@interface DirectMessageCellView : UIView {
    DirectMessage*  message;
}

@property(nonatomic, retain) DirectMessage* message;

@end
