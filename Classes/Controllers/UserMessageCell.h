//
//  UserMessageCell.h
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

typedef enum {
    USER_CELL_NORMAL,
    USER_CELL_LOAD_BUTTON,
} UserCellType;

@interface UserMessageCell : UITableViewCell {
    Message*        message;
    UILabel*        textLabel;
    UILabel*        timestamp;
    UILabel*        source;
    UserCellType    type;
}

-(void)setType:(UserCellType)type;

@property(nonatomic, assign) Message* message;

@end
