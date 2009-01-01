//
//  UserStore.m
//  TwitterFon
//
//  Created by kaz on 12/31/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserStore.h"

static NSMutableDictionary* users = nil;
static NSMutableDictionary* usersById = nil;

@implementation UserStore

+ (void)initDictionary
{
    if (users == nil) {
        users = [[NSMutableDictionary dictionary] retain];
        usersById = [[NSMutableDictionary dictionary] retain];
    }    
}

+ (void)setUser:(User*)user
{
    [UserStore initDictionary];

    [users setObject:user forKey:user.screenName];
    NSString *key = [NSString stringWithFormat:@"%d", user.userId];
    [usersById setObject:user forKey:key];
}

+ (User*)getUser:(NSString*)screenName
{
    [UserStore initDictionary];
    
    if ([screenName isKindOfClass:[NSString class]]) {
        return [users objectForKey:screenName];
    }
    else {
        return nil;
    }
}

+ (User*)getUserWithId:(int)id
{
    [UserStore initDictionary];
    
    NSString *key = [NSString stringWithFormat:@"%d", id];
    return [usersById objectForKey:key];
}

@end
