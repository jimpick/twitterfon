//
//  ChatBubbleCell.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImageCell.h"
#import "ChatBubbleView.h"

@class Tweet;
@class ChatBubbleView;

@interface ChatBubbleCell : ProfileImageCell 
{
    Tweet*              message;
    ChatBubbleView*     cellView;
}

- (void)setMessage:(Tweet*)msg type:(BubbleType)type;

+ (CGFloat)calcCellHeight:(Tweet*)msg interval:(int)diff;

@end
