//
//  Followee.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Followee.h"

#import "DBConnection.h"

static sqlite3_stmt* replace_statement = nil;
static sqlite3_stmt* delete_statement = nil;

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

+ (Followee*)initWithDB:(sqlite3_stmt*)statement
{
    Followee *followee       = [[Followee alloc] init];
    followee.userId          = (int)sqlite3_column_text(statement, 0);
    followee.name            = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
    followee.screenName      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
    followee.profileImageUrl = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    
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
    if (replace_statement == nil) {
        replace_statement = [DBConnection prepate:"REPLACE INTO followees VALUES(?, ?, ?, ?)"];
    }
    
    sqlite3_bind_int(replace_statement,  1, user.userId);
    sqlite3_bind_text(replace_statement, 2, [user.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(replace_statement, 3, [user.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(replace_statement, 4, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(replace_statement);
    sqlite3_reset(replace_statement);
    if (success == SQLITE_ERROR) {
        [DBConnection assertWithMessage:@"Failed to execute SQL"];
    }
}

+ (void)deleteFromDB:(User*)user
{
    if (delete_statement == nil) {
        delete_statement = [DBConnection prepate:"DELETE FROM followees WHERE user_id = ?"];
    }
    
    sqlite3_bind_int(delete_statement,  1, user.userId);
    
    int success = sqlite3_step(delete_statement);
    sqlite3_reset(delete_statement);
    if (success == SQLITE_ERROR) {
        [DBConnection assertWithMessage:@"Failed to execute SQL command"];
    }
}

@end
