//
//  PostImagePickerController.h
//  TwitterFon
//
//  Created by kaz on 11/1/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostViewController;

@interface PostImagePickerController : UIImagePickerController
{
    PostViewController* postViewController;
}

@property(nonatomic, assign) PostViewController* postViewController;

@end
