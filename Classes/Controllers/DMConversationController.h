//
//  DMConversationController.h
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirectMessage;

@interface DMConversationController : UITableViewController 
{
    NSMutableArray*     messages;
    DirectMessage*      firstMessage;
    BOOL                isFirstTime;
}

- (id)initWithMessage:(DirectMessage*)message;

@end
