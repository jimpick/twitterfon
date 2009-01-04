//
//  FolloweeCellView.h
//  TwitterFon
//
//  Created by kaz on 1/3/09.
//  Copyright 2009 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Followee;

@interface FolloweeCellView : UIView 
{
    NSString*   screenName;
    NSString*   name;
}

@property(nonatomic, retain) NSString *screenName;
@property(nonatomic, retain) NSString *name;

@end
