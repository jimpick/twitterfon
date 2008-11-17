//
//  UserView.h
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserView : UIView {
    User*       user;
  	UIButton*   url;

    UIImage*    profileImage;
    UIImage*    lockIcon;
    
    CGImageRef  background;
    
    BOOL        hasDetail;
    BOOL        protected;
    
    float       height;
}

@property(nonatomic, assign) User*      user;
@property(nonatomic, assign) BOOL       protected;
@property(nonatomic, retain) UIImage*   profileImage;
@property(nonatomic, assign) float      height;
@property(nonatomic, assign) BOOL       hasDetail;

-(void)setUser:(User*)user delegate:(id)delegate;

@end
