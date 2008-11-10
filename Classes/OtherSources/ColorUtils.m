//
//  ColorUtils.m
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ColorUtils.h"

static UIColor *gNavigationBarColors[4];
static UIColor *gUnreadCellColors[4];

@implementation UIColor (NSStringUtils)

+ (void) initTwitterFonColorScheme
{
    gUnreadCellColors[0] = [[UIColor colorWithRed:0.910 green:1.000 blue:1.000 alpha:1.0] retain];
    gUnreadCellColors[1] = [[UIColor colorWithRed:0.886 green:1.000 blue:0.878 alpha:1.0] retain];
    gUnreadCellColors[2] = [[UIColor colorWithRed:0.992 green:0.875 blue:0.878 alpha:1.0] retain];
    gUnreadCellColors[3] = [UIColor whiteColor];
    
    // Navigation Bar Color
    gNavigationBarColors[0] = [[UIColor colorWithRed:0.341 green:0.643 blue:0.859 alpha:1.0] retain];
    gNavigationBarColors[1] = [[UIColor colorWithRed:0.459 green:0.663 blue:0.557 alpha:1.0] retain];
    gNavigationBarColors[2] = [[UIColor colorWithRed:0.701 green:0.447 blue:0.459 alpha:1.0] retain];
    gNavigationBarColors[3] = [UIColor whiteColor];
    
}

+ (UIColor*)navigationColorForTab:(int)tab
{
    return gNavigationBarColors[tab];
}

+ (UIColor*)cellColorForTab:(int)tab
{
    return gUnreadCellColors[tab];
}

@end
