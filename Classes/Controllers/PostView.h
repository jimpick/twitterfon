//
//  PostView.h
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostView : UIView {
    CGImageRef  background;
    BOOL        showRecipient;
}

@property(nonatomic) BOOL showRecipient;

@end
