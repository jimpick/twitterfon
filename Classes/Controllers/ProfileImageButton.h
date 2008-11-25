//
//  ProfileImageButton.h
//  TwitterFon
//
//  Created by kaz on 11/24/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileImageButton : UIControl {
    UIImage*    image;
}

- (void)setImage:(UIImage*)anImage forState:(UIControlState)state;

@end
