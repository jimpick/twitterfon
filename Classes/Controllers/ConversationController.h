//
//  DMConversationController.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadEarlierMessageCell.h"

@class Tweet;

@interface ConversationController : UITableViewController 
{
    LoadEarlierMessageCell* loadCell;
    NSMutableArray*         messages;
    Tweet*                  firstMessage;
    BOOL                    isFirstTime;
    BOOL                    hasMore;
    CGPoint                 contentOffset;
}

- (id)initWithMessage:(Tweet*)message;

@end
