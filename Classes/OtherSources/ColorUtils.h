//
//  ColorUtils.h
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColorUtils)
+ (void)initTwitterFonColorScheme;
+ (UIColor*)friendColor:(BOOL)unread;
+ (UIColor*)repliesColor:(BOOL)unread;
+ (UIColor*)messageColor:(BOOL)unread;
@end