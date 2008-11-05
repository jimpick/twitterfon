//
//  Followee.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Followee.h"

#import "DBConnection.h"

static sqlite3_stmt* select_statement = nil;
static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* update_statement = nil;

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

+ (BOOL)isExists:(User*)user
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (select_statement== nil) {
        static char *sql = "SELECT profile_image_url FROM followees WHERE user_id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int64(select_statement, 1, user.userId);
    BOOL result = (sqlite3_step(select_statement) == SQLITE_ROW) ? true : false;

    NSString *profileImageUrl;
    if (result) {
        profileImageUrl = [NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 0)];
    }
    sqlite3_reset(select_statement);
    
    if (result && [user.profileImageUrl isEqualToString:profileImageUrl] == false) {
        [Followee updateDB:user];
    }
    
    return result;
}

+ (void)updateDB:(User*)user
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (update_statement == nil) {
        static char *sql = "UPDATE followees SET profile_image_url = ? WHERE user_id = ?";
        if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_text(update_statement, 1, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(update_statement, 2, user.userId);
    
    int success = sqlite3_step(update_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(update_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
}

+ (void)insertDB:(User*)user
{
    if ([Followee isExists:user]) {
        return;
    }
    
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO followees VALUES(?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int(insert_statement,  1, user.userId);
    sqlite3_bind_text(insert_statement, 2, [user.name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [user.screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 4, [user.profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }
}

@end
