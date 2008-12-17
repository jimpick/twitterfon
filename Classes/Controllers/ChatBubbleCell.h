//
//  ChatBubbleCell.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirectMessage;
@class ChatBubbleView;

@interface ChatBubbleCell : UITableViewCell 
{
    DirectMessage*      message;
    ChatBubbleView*     cellView;
}

- (void)setMessage:(DirectMessage*)msg isOwn:(BOOL)isOwnMessage;

@end
