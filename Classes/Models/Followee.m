//
//  Followee.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Followee.h"

#import "DBConnection.h"

@interface NSObject (FolloweeDelegate)
- (void)followeeDidGetFollowee:(Followee*)Followee;
@end

@implementation Followee

@synthesize userId;
@synthesize name;
@synthesize screenName;
@synthesize profileImageUrl;

- (void)dealloc
{
    [name release];
    [screenName release];
    [profileImageUrl release];
    [super dealloc];
}

+ (Followee*)initWithStatement:(Statement*)stmt
{
    Followee *followee       = [[Followee alloc] init];
    followee.userId          = [stmt getInt32:0];
    followee.name            = [stmt getString:1];
    followee.screenName      = [stmt getString:2];
    followee.profileImageUrl = [stmt getString:3];
    
    return followee;
}

+ (void)updateDB:(User*)user
{
    if (user.following) {
        [Followee insertDB:user];
    }
    else {
        [Followee deleteFromDB:user];
    }
}

+ (void)insertDB:(User*)user
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO followees VALUES(?, ?, ?, ?)"];
        [stmt retain];
    }
    
    [stmt bindInt32:user.userId             forIndex:1];
    [stmt bindString:user.name              forIndex:2];
    [stmt bindString:user.screenName        forIndex:3];
    [stmt bindString:user.profileImageUrl   forIndex:4];

    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection alert];
    }
    [stmt reset];
}

+ (void)deleteFromDB:(User*)user
{
    Statement *stmt = [DBConnection statementWithQuery:"DELETE FROM followees WHERE user_id = ?"];

    [stmt bindInt32:user.userId forIndex:1];

    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection alert];
    }
}

@end
