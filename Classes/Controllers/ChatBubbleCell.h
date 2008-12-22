//
//  ChatBubbleCell.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileImageCell.h"

@class DirectMessage;
@class ChatBubbleView;

@interface ChatBubbleCell : ProfileImageCell 
{
    DirectMessage*      message;
    ChatBubbleView*     cellView;
}

- (void)setMessage:(DirectMessage*)msg isOwn:(BOOL)isOwnMessage;

@end
