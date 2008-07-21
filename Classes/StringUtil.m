//
//  StringUtil.m
//  TwitterFon
//
//  Created by kaz on 7/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "StringUtil.h"

@implementation NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent
{
    NSString* s = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8);
    return [s autorelease];
}
@end