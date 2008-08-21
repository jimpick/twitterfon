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
    IBOutlet UILabel*       description;
  	IBOutlet UIButton*      url;
    IBOutlet UILabel*       numFollowers;
    IBOutlet UIImageView*   profileImage;
}

@property(nonatomic, assign) Message* message;
@property(nonatomic, assign) UIImageView* profileImage;

@end
