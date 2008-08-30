//
//  ColorUtils.h
//  TwitterFon
//
//  Created by kaz on 7/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#else
#  define LOG(...) ;
#endif

#define __FUNC_NAME__ NSLog(NSStringFromSelector(_cmd)); 
