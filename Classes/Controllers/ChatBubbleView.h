//
//  ChatBubbleView.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    BUBBLE_TYPE_GRAY,
    BUBBLE_TYPE_GREEN,
} BubbleType;

@interface ChatBubbleView : UIView
{
    BubbleType  type;
}

@property(nonatomic, assign) BubbleType type;

@end
