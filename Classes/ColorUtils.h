//
//  ColorUtils.h
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorUtils)
+ (UIColor*)friendColor;
+ (UIColor*)friendColor:(BOOL)unread;
+ (UIColor*)friendColorBorder;
+ (UIColor*)repliesColor;
+ (UIColor*)repliesColor:(BOOL)unread;
+ (UIColor*)repliesColorBorder;
+ (UIColor*)messageColor;
+ (UIColor*)messageColor:(BOOL)unread;
+ (UIColor*)messageColorBorder;
@end