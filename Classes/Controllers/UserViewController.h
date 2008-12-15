//
//  UserViewController.h
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"
#import "UserViewActionCell.h"
#import "UserMessageCell.h"
#import "TwitterClient.h"
#import "DeleteButtonCell.h"

@interface UserViewController : UITableViewController <UIActionSheetDelegate> {
    UserView*               userView;
    UserViewActionCell*     actionCell;
    UserMessageCell*        messageCell;
    DeleteButtonCell*       deleteCell;
    Message*                message;
    Message*                inReplyToMessage;
    User*                   inReplyToUser;
    TwitterClient*          twitterClient;
    BOOL                    hasDeleteButton;
    BOOL                    isDirectMessage;
}

- (id)initWithMessage:(Message*)message;
- (id)initWithMessageId:(sqlite_int64)messageId;

@end
