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

@interface UserViewController : UITableViewController {
    UserView*               userView;
    UserViewActionCell*     actionCell;
    MessageCell*            messageCell;
    DeleteButtonCell*       deleteCell;
    Message*                message;
    TwitterClient*          twitterClient;
    BOOL                    isOwnMessage;
}

- (id)initWithMessage:(Message*)message;

@end
