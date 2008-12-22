//
//  ProfileImageView.m
//  TwitterFon
//
//  Created by kaz on 12/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ProfileImageView.h"
#import "TwitterFonAppDelegate.h"

@implementation ProfileImageView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _receiver = [[ImageStoreReceiver alloc] init];
    }
    return self;
}

- (UIImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag
{
    ImageStore *store = [TwitterFonAppDelegate getAppDelegate].imageStore;
    _profileImage = [store getProfileImage:url isLarge:flag delegate:_receiver];
    _receiver.imageContainer = self;
    return _profileImage.image;
}

- (void)dealloc {
    _receiver.imageContainer = nil;
    if (_profileImage) {
        [_profileImage removeDelegate:_receiver];
    }
    [_receiver release];
    [super dealloc];
}

@end
