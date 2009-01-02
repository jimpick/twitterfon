//
//  DMConversationController.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadEarlierMessageCell.h"

@class DirectMessage;

@interface DMConversationController : UITableViewController 
{
    LoadEarlierMessageCell* loadCell;
    NSMutableArray*         messages;
    DirectMessage*          firstMessage;
    BOOL                    isFirstTime;
    BOOL                    hasMore;
}

- (id)initWithMessage:(DirectMessage*)message;

@end
