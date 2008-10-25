//
//  ColorUtils.m
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ColorUtils.h"


static UIColor *sFriendColorUnread   = nil;
static UIColor *sRepliesColorUnread  = nil;
static UIColor *sMessageColorUnread  = nil;

UIColor *gNavigationBarColors[3];

@implementation UIColor (NSStringUtils)

+ (void) initTwitterFonColorScheme
{
    sFriendColorUnread   = [[UIColor colorWithRed:0.894 green:0.976 blue:0.988 alpha:1.0] retain];
    sRepliesColorUnread  = [[UIColor colorWithRed:0.863 green:0.925 blue:0.886 alpha:1.0] retain];
    sMessageColorUnread  = [[UIColor colorWithRed:0.969 green:0.863 blue:0.855 alpha:1.0] retain];

    // Navigation Bar Color
    gNavigationBarColors[0] = [[UIColor colorWithRed:0.420 green:0.690 blue:0.878 alpha:1.0] retain];
    gNavigationBarColors[1] = [[UIColor colorWithRed:0.459 green:0.663 blue:0.557 alpha:1.0] retain];
    gNavigationBarColors[2] = [[UIColor colorWithRed:0.701 green:0.447 blue:0.459 alpha:1.0] retain];
    
}

+ (UIColor*)friendColor:(BOOL)unread
{
    return unread ? sFriendColorUnread : [UIColor whiteColor];
}

+ (UIColor*)repliesColor:(BOOL)unread
{

    return unread ? sRepliesColorUnread : [UIColor whiteColor];
}

+ (UIColor*)messageColor:(BOOL)unread
{
    return unread ? sMessageColorUnread : [UIColor whiteColor];
}

@end
