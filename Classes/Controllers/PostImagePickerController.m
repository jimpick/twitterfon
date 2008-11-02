//
//  PostImagePickerController.m
//  TwitterFon
//
//  Created by kaz on 11/1/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "PostViewController.h"
#import "PostImagePickerController.h"

@implementation PostImagePickerController

@synthesize postViewController;

- (void)viewDidDisappear:(BOOL)animated 
{
    [postViewController imagePickerControllerDidDisappear];
}

- (void)dealloc {
    [super dealloc];
}


@end
