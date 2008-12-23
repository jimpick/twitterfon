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
    if (_profileImageUrl != url) {
        [_profileImageUrl release];
    }
    _profileImageUrl = [url copy];
    
    ImageStore *store = [TwitterFonAppDelegate getAppDelegate].imageStore;
    UIImage *image = [store getProfileImage:url isLarge:flag delegate:_receiver];
    _receiver.imageContainer = self;
    return image;
}

- (void)dealloc {
    _receiver.imageContainer = nil;
    ImageStore *store = [TwitterFonAppDelegate getAppDelegate].imageStore;
    [store removeDelegate:_receiver forURL:_profileImageUrl];
    [_profileImageUrl release];
    [_receiver release];
    [super dealloc];
}

@end
