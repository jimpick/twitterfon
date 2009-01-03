//
//  DMDetailViewController.h
//  TwitterFon
//
//  Created by kaz on 11/30/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserView.h"
#import "TwitterClient.h"
#import "DirectMessage.h"
#import "DeleteButtonCell.h"
#import "DMDetailCell.h"

@interface DMDetailViewController : UITableViewController <UIActionSheetDelegate>
{
    UserView*               userView;
    DMDetailCell*           messageCell;
    DeleteButtonCell*       deleteCell;
    DirectMessage*          message;
    TwitterClient*          twitterClient;
    BOOL                    isOwnMessage;
}

- (id)initWithMessage:(DirectMessage*)message;

@end
