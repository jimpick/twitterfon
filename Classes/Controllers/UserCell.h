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
	UILabel*        name;
	UILabel*        location;
  	UIButton*       url;
    UILabel*        numFollowers;
    UIImageView*    protected;
    NSString*       urlString;
}

-(void)update:(Message*)message delegate:(id)delegate;

@end
