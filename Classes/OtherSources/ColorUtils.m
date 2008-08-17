//
//  ColorUtils.m
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ColorUtils.h"


static UIColor *sFriendColor         = nil;
static UIColor *sFriendColorUnread   = nil;
static UIColor *sRepliesColor        = nil;
static UIColor *sRepliesColorUnread  = nil;
static UIColor *sMessageColor        = nil;
static UIColor *sMessageColorUnread  = nil;

@implementation UIColor (NSStringUtils)

+ (void) initTwitterFonColorScheme
{
    sFriendColor         = [[UIColor colorWithRed:0.682 green:0.914 blue:0.925 alpha:1.0] retain];    
    sFriendColorUnread   = [[UIColor colorWithRed:0.451 green:0.898 blue:0.898 alpha:1.0] retain];
    sRepliesColor        = [[UIColor colorWithRed:0.745 green:0.910 blue:0.608 alpha:1.0] retain];
    sRepliesColorUnread  = [[UIColor colorWithRed:0.671 green:0.898 blue:0.443 alpha:1.0] retain];
    sMessageColor        = [[UIColor colorWithRed:0.878 green:0.729 blue:0.545 alpha:1.0] retain];
    sMessageColorUnread  = [[UIColor colorWithRed:0.898 green:0.671 blue:0.443 alpha:1.0] retain];
}

+ (UIColor*)friendColor:(BOOL)unread
{
    return unread ? sFriendColorUnread : sFriendColor;
}

+ (UIColor*)repliesColor:(BOOL)unread
{

    return unread ? sRepliesColorUnread : sRepliesColor;
}

+ (UIColor*)messageColor:(BOOL)unread
{
    return unread ? sMessageColorUnread : sMessageColor;
}

@end
