//
//  ImageStoreReceiver.m
//  TwitterFon
//
//  Created by kaz on 12/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ImageStoreReceiver.h"


@implementation ImageStoreReceiver

@synthesize imageContainer;

- (void)dealloc
{
    imageContainer = nil;
    [super dealloc];
}

- (void)profileImageDidGetNewImage:(UIImage*)image
{
    if (imageContainer) {
        if ([imageContainer respondsToSelector:@selector(updateImage:)]) {
            [imageContainer performSelector:@selector(updateImage:) withObject:image];
        }
    }
}

@end
