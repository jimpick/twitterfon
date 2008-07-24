//
//  UserCell.h
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface UserCell : UITableViewCell {
    IBOutlet UILabel*       screen_name;
    IBOutlet UILabel*       name;
    IBOutlet UILabel*       location;
    IBOutlet UIButton*      url;
    IBOutlet UILabel*       description;
    IBOutlet UIImageView*   profile_image;
}

- (void)initWithMessage:(Message*)m withImage:(UIImage*)image;

@end
