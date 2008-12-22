//
//  ProfileImageCell.m
//  TwitterFon
//
//  Created by kaz on 12/22/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ProfileImageCell.h"
#import "TwitterFonAppDelegate.h"

@implementation ProfileImageCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        _profileImage = nil;
        _receiver = [[ImageStoreReceiver alloc] init];
    }
    return self;
}

- (void)updateImage:(UIImage*)image
{
    // Perhaps, you need re-implement on deliver class
    self.image = image;
    [self setNeedsDisplay];
    [self setNeedsLayout];    
}

- (UIImage*)getProfileImage:(NSString*)url isLarge:(BOOL)flag
{
    ImageStore *store = [TwitterFonAppDelegate getAppDelegate].imageStore;
    _profileImage = [store getProfileImage:url isLarge:flag delegate:_receiver];
    _receiver.imageContainer = self;
    return _profileImage.image;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    if (_profileImage) {
        [_profileImage removeDelegate:_receiver];
        _profileImage = nil;
    }
    _receiver.imageContainer = nil;
}

- (void)dealloc {
    _receiver.imageContainer = nil;
    if (_profileImage) {
        [_profileImage removeDelegate:_receiver];
        _profileImage = nil;
    }
    [_receiver release];
    [super dealloc];
}


@end
