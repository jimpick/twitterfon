//
//  UserCell.h
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface UserCell : UITableViewCell {
	Message*                message;
    
	IBOutlet UILabel*       name;
	IBOutlet UILabel*       location;
  	IBOutlet UIButton*      url;
    IBOutlet UILabel*       numFollowers;
    IBOutlet UIImageView*   profileImage;
    IBOutlet UIImageView*   protected;
    
    NSObject*               delegate;
}

@property(nonatomic, copy) Message* message;
@property(nonatomic, assign) UIImageView* profileImage;

-(CGFloat)calcCellHeight;

@end
