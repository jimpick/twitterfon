//
//  UserViewController.h
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"
#import "TweetViewActionCell.h"
#import "UserMessageCell.h"
#import "TwitterClient.h"
#import "DeleteButtonCell.h"

@interface TweetViewController : UITableViewController <UIActionSheetDelegate> {
    UserView*               userView;
    UserMessageCell*        messageCell;
    TweetViewActionCell*    actionCell;
    DeleteButtonCell*       deleteCell;
    Message*                message;
    Message*                inReplyToMessage;
    User*                   inReplyToUser;
    TwitterClient*          twitterClient;
    BOOL                    isOwnTweet;
    BOOL                    isDirectMessage;
    int                     *sections;
}

- (id)initWithMessage:(Message*)message;
- (id)initWithMessageId:(sqlite_int64)messageId;

@end
