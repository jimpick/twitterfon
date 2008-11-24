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

+ (void)insertDB:(User*)user
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (replace_statement == nil) {
        static char *sql = "REPLACE INTO followees VALUES(?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &replace_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int(replace_statement,  1, user.userId);
    sqlite3_bind_text(replace_statement, 2, [user.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(replace_statement, 3, [user.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(replace_statement, 4, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(replace_statement);
    sqlite3_reset(replace_statement);
    if (success == SQLITE_ERROR) {
        NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
    }
}

@end
