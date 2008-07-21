//
//  ColorUtils.m
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ColorUtils.h"


static UIColor *friendColor         = nil;
static UIColor *friendColorUnread   = nil;
static UIColor *friendColorBorder   = nil;
static UIColor *repliesColor        = nil;
static UIColor *repliesColorUnread  = nil;
static UIColor *repliesColorBorder  = nil;
static UIColor *messageColor        = nil;
static UIColor *messageColorUnread  = nil;
static UIColor *messageColorBorder  = nil;


@implementation UIColor (NSStringUtils)

+ (UIColor*)friendColor
{
    if (friendColor == nil) {
        friendColor = [[UIColor colorWithRed:0.682 green:0.914 blue:0.925 alpha:1.0] retain];
    }
    return friendColor;
}
+ (UIColor*)friendColor:(BOOL)unread
{
    if (friendColorUnread == nil) {
        friendColorUnread = [[UIColor colorWithRed:0.451 green:0.898 blue:0.898 alpha:1.0] retain];
    }
    return unread ? friendColorUnread : [UIColor friendColor];
}
+ (UIColor*)friendColorBorder
{
    if (friendColorBorder == nil) {
        friendColorBorder = [[UIColor colorWithRed:0.784 green:0.969 blue:0.996 alpha:1.0] retain];
    }
    return friendColorBorder;
}
+ (UIColor*)repliesColor
{
    if (repliesColor == nil) {
        repliesColor = [[UIColor colorWithRed:0.745 green:0.910 blue:0.608 alpha:1.0] retain];
    }
    return repliesColor;
}
+ (UIColor*)repliesColor:(BOOL)unread
{
    if (repliesColorUnread == nil) {
        repliesColorUnread = [[UIColor colorWithRed:0.671 green:0.898 blue:0.443 alpha:1.0] retain];
    }
    return unread ? repliesColorUnread : repliesColor;
}
+ (UIColor*)repliesColorBorder
{
    if (repliesColorBorder == nil) {
        repliesColorBorder = [[UIColor colorWithRed:0.894 green:1.000 blue:0.800 alpha:1.0] retain];
    }
    return repliesColorBorder;
}
+ (UIColor*)messageColor
{
    if (messageColor == nil) {
        messageColor = [[UIColor colorWithRed:0.878 green:0.729 blue:0.545 alpha:1.0] retain];
    }
    return messageColor;
}
+ (UIColor*)messageColor:(BOOL)unread
{
    if (messageColorUnread == nil) {
        messageColorUnread = [[UIColor colorWithRed:0.898 green:0.671 blue:0.443 alpha:1.0] retain];
    }
    return unread ? messageColorUnread : messageColor;
}
+ (UIColor*)messageColorBorder
{
    if (messageColorBorder == nil) {
        messageColorBorder = [[UIColor colorWithRed:0.992 green:0.910 blue:0.800 alpha:1.0] retain];
    }
    return messageColorBorder;
}

@end
