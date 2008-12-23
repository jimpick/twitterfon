//
//  ProfileImageView.h
//  TwitterFon
//
//  Created by kaz on 12/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageStoreReceiver.h"

@interface ProfileImageView : UIView {
    NSString*               _profileImageUrl;
    ImageStoreReceiver*     _receiver;
}

- (UIImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag;

@end
