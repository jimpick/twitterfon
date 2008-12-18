//
//  ChatBubbleView.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectMessage.h"

typedef enum {
    BUBBLE_TYPE_GRAY,
    BUBBLE_TYPE_GREEN,
} BubbleType;

@interface ChatBubbleView : UIView
{
    BubbleType      type;
    DirectMessage*  message;
    UIImage*        image;
}

- (void)setMessage:(DirectMessage*)message type:(BubbleType)type;

@end
