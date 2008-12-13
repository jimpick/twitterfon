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
#import "MessageCell.h"
#import "TwitterClient.h"
#import "DeleteButtonCell.h"

@interface UserViewController : UITableViewController <UIActionSheetDelegate> {
    UserView*               userView;
    UserViewActionCell*     actionCell;
    MessageCell*            messageCell;
    DeleteButtonCell*       deleteCell;
    Message*                message;
    TwitterClient*          twitterClient;
    BOOL                    hasDeleteButton;
    BOOL                    isDirectMessage;
}

- (id)initWithMessage:(Message*)message;

@end
