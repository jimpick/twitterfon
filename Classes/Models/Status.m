#import "Status.h"
#import "Followee.h"
#import "DBConnection.h"
#import "REString.h"
#import "StringUtil.h"

static sqlite3_stmt* insert_statement = nil;
static sqlite3_stmt* select_statement = nil;
static sqlite3_stmt* status_by_id     = nil;

@interface Status (Private)
- (void)insertDB;
@end

@implementation Status

@synthesize statusId;
@synthesize user;
@synthesize source;
@synthesize favorited;
@synthesize truncated;

@synthesize textBounds;
@synthesize cellHeight;
@synthesize inReplyToStatusId;
@synthesize inReplyToUserId;
@synthesize inReplyToScreenName;

- (void)dealloc
{
    [user release];
    [source release];
  	[super dealloc];
}

- (Status*)initWithJsonDictionary:(NSDictionary*)dic type:(TweetType)aType
{
	self = [super init];
    
    type = aType;
    cellType = TWEET_CELL_TYPE_NORMAL;
    
	statusId           = [[dic objectForKey:@"id"] longLongValue];
    stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    if ((id)stringOfCreatedAt == [NSNull null]) {
        stringOfCreatedAt = @"";
    }

    favorited = [dic objectForKey:@"favorited"] == [NSNull null] ? 0 : [[dic objectForKey:@"favorited"] boolValue];
    truncated = [dic objectForKey:@"truncated"] == [NSNull null] ? 0 : [[dic objectForKey:@"truncated"] boolValue];
    
    NSString *tweet = [dic objectForKey:@"text"];

    if ((id)tweet == [NSNull null]) {
        text = @"";
    }
    else {
        tweet = [[tweet unescapeHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        text  = [[tweet stringByReplacingOccurrencesOfString:@"\r" withString:@" "] retain];
    }

    // parse source parameter
    NSString *src = [dic objectForKey:@"source"];
    if (src == nil) {
        source = @"";
    }
    else if ((id)src == [NSNull null]) {
        source = @"";
    }
    else {
        NSRange r = [src rangeOfString:@"<a href"];
        if (r.location != NSNotFound) {
            NSRange start = [src rangeOfString:@"\">"];
            NSRange end   = [src rangeOfString:@"</a>"];
            if (start.location != NSNotFound && end.location != NSNotFound) {
                r.location = start.location + start.length;
                r.length = end.location - r.location;
                source = [[src substringWithRange:r] retain];
            }
        }
        else {
            source = [src retain];
        }
    }
    
    inReplyToStatusId   = [dic objectForKey:@"in_reply_to_status_id"]   == [NSNull null] ? 0 : [[dic objectForKey:@"in_reply_to_status_id"] longLongValue];
    inReplyToUserId     = [dic objectForKey:@"in_reply_to_user_id"]     == [NSNull null] ? 0 : [[dic objectForKey:@"in_reply_to_user_id"] longValue];
    inReplyToScreenName = [dic objectForKey:@"in_reply_to_screen_name"];
    if ((id)inReplyToScreenName == [NSNull null]) inReplyToScreenName = @"";
    if (inReplyToScreenName == nil) inReplyToScreenName = @"";
    [inReplyToScreenName retain];
	
	NSDictionary* userDic = [dic objectForKey:@"user"];
	if (userDic) {
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    else {
        if (type == TWEET_TYPE_MESSAGES) {
            userDic = [dic objectForKey:@"sender"];
        }
        else {
            userDic = [dic objectForKey:@"recipient"];
        }
        user = [[User alloc] initWithJsonDictionary:userDic];
    }

    [self updateAttribute];
    unread = true;

	return self;
}

- (Status*)initWithSearchResult:(NSDictionary*)dic
{
	self = [super init];
    
    type = TWEET_TYPE_SEARCH_RESULT;
    cellType = TWEET_CELL_TYPE_NORMAL;
    
	statusId           = [[dic objectForKey:@"id"] longLongValue];
    stringOfCreatedAt   = [dic objectForKey:@"created_at"];
    if ((id)stringOfCreatedAt == [NSNull null]) {
        stringOfCreatedAt = @"";
    }
    
    NSString *tweet = [dic objectForKey:@"text"];
    
    if ((id)tweet == [NSNull null]) {
        text = @"";
    }
    else {
        tweet = [[tweet  unescapeHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        text  = [[tweet stringByReplacingOccurrencesOfString:@"\r" withString:@" "] retain];
    }
    
    // parse source parameter
    source = @"";
    
    user = [[User alloc] initWithSearchResult:dic];
    
    [self updateAttribute];
    
	return self;
}

+ (Status*)statusWithJsonDictionary:(NSDictionary*)dic type:(TweetType)type
{
	return [[[Status alloc] initWithJsonDictionary:dic type:type] autorelease];
}

+ (Status*)statusWithSearchResult:(NSDictionary*)dic
{
	return [[[Status alloc] initWithSearchResult:dic] autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
    Status *dist = [[Status allocWithZone:zone] init];
    
	dist.statusId  = statusId;
	dist.user      = [user copy];
    [dist.user release];
    dist.source     = source;
    dist.favorited  = favorited;
    dist.truncated  = truncated;

    dist.inReplyToStatusId   = inReplyToStatusId;
    dist.inReplyToUserId     = inReplyToUserId;
    dist.inReplyToScreenName = inReplyToScreenName;
    
    [super copyWithZone:dist];
    
    return dist;
}

- (void)calcTextBounds:(int)textWidth
{
    CGRect bounds, result;
    
    if (cellType == TWEET_CELL_TYPE_NORMAL) {
        bounds = CGRectMake(0, TOP, textWidth, 200);
    }
    else {
        bounds = CGRectMake(0, 3, textWidth, 200);
    }

    static UILabel *label = nil;
    if (label == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    label.font = [UIFont systemFontOfSize:(cellType == TWEET_CELL_TYPE_DETAIL) ? 14 : 13];
    label.text = text;
    result = [label textRectForBounds:bounds limitedToNumberOfLines:10];
    
    textBounds = CGRectMake(bounds.origin.x, bounds.origin.y, textWidth, result.size.height);
    
    if (cellType == TWEET_CELL_TYPE_NORMAL) {
        result.size.height += 18 + 15 + 2;
        if (result.size.height < IMAGE_WIDTH + 1) result.size.height = IMAGE_WIDTH + 1;
    }
    else {
        result.size.height += 22;
    }
    cellHeight = result.size.height;
}

int sTextWidth[] = {
    CELL_WIDTH,
    USER_CELL_WIDTH,
    DETAIL_CELL_WIDTH,
};

- (void)updateAttribute
{
    [super updateAttribute];
    int textWidth = sTextWidth[cellType];
    if (cellType == TWEET_CELL_TYPE_DETAIL && 
        (type == TWEET_TYPE_MESSAGES || type == TWEET_TYPE_SENT)) {
        textWidth += STAR_BUTTON_WIDTH;
    }
    
    if (accessoryType = UITableViewCellAccessoryDetailDisclosureButton) {
        textWidth -= DETAIL_BUTTON_WIDTH;
    }
    else if (cellType == TWEET_CELL_TYPE_DETAIL) {
        textWidth -= H_MARGIN;
    }
    else {
        textWidth -= INDICATOR_WIDTH;
    }
    // Calculate text bounds and cell height here
    //
    [self calcTextBounds:textWidth];
}

+ (Status*)statusWithId:(sqlite_int64)aStatusId
{
    if (status_by_id == nil) {
        status_by_id = [DBConnection prepate:"SELECT * FROM statuses,users WHERE statuses.user_id = users.user_id AND id = ?"];
    }
    
    sqlite3_bind_int64(status_by_id, 1, aStatusId);
    int ret = sqlite3_step(status_by_id);
    if (ret != SQLITE_ROW) {
        sqlite3_reset(status_by_id);
        return nil;
    }
    
    Status *s = [Status initWithDB:status_by_id type:TWEET_TYPE_FRIENDS];
    sqlite3_reset(status_by_id);
    return s;
}

+ (Status*)initWithDB:(sqlite3_stmt*)statement type:(TweetType)type
{
    // sqlite3 statement should be:
    //  SELECT * FROM messsages,users
    //
    Status *s               = [[[Status alloc] init] autorelease];
    s.user                  = [[User alloc] init];
    
    s.statusId             = (sqlite_int64)sqlite3_column_int64(statement, 0);
    s.text                  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    s.createdAt             = (time_t)sqlite3_column_int(statement, 4);
    s.source                = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
    s.favorited             = (BOOL)sqlite3_column_int(statement, 6);
    s.truncated             = (BOOL)sqlite3_column_int64(statement, 7);
    s.inReplyToStatusId     = (sqlite_int64)sqlite3_column_int64(statement, 8);
    s.inReplyToUserId       = (uint32_t)sqlite3_column_int64(statement, 9);
    s.inReplyToScreenName   = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 10)];
    
    s.user.userId           = (uint32_t)sqlite3_column_int(statement, 11);
    s.user.name             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 12)];
    s.user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 13)];
    s.user.location         = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 14)];
    s.user.description      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 15)];
    s.user.url              = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 16)];
    s.user.followersCount   = (uint32_t)sqlite3_column_int(statement, 17);
    s.user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 18)];
    s.user.protected        = (uint32_t)sqlite3_column_int(statement, 19) ? true : false;
    s.unread                = false;
    s.type                  = type;

    s.cellType = TWEET_CELL_TYPE_NORMAL;
    [s updateAttribute];
    
    return s;
}

+ (BOOL)isExists:(sqlite_int64)aStatusId type:(TweetType)aType
{
    if (select_statement== nil) {
        select_statement = [DBConnection prepate:"SELECT id FROM statuses WHERE id=? and type=?"];
    }
    
    sqlite3_bind_int64(select_statement, 1, aStatusId);
    sqlite3_bind_int(select_statement, 2, aType);
    BOOL result = (sqlite3_step(select_statement) == SQLITE_ROW) ? true : false;
    sqlite3_reset(select_statement);
    return result;
}

- (void)insertDB
{
    if (insert_statement == nil) {
        insert_statement = [DBConnection prepate:"INSERT INTO statuses VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    sqlite3_bind_int64(insert_statement, 1, statusId);
    sqlite3_bind_int(insert_statement,   2, type);
    sqlite3_bind_int(insert_statement,   3, user.userId);
    
    sqlite3_bind_text(insert_statement,  4, [text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   5, createdAt);
    sqlite3_bind_text(insert_statement,  6, [source UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,   7, favorited);
    sqlite3_bind_int(insert_statement,   8, truncated);
    sqlite3_bind_int64(insert_statement, 9, inReplyToStatusId);
    sqlite3_bind_int(insert_statement,  10, inReplyToUserId);
    sqlite3_bind_text(insert_statement, 11, [inReplyToScreenName UTF8String], -1, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }

    // Update user and followee record
    [user updateDB];
    
    if (type == TWEET_TYPE_FRIENDS) {
        [Followee insertDB:user];
    }
}

- (void)insertDBIfFollowing
{
    sqlite3_stmt *stmt = [DBConnection prepate:"SELECT user_id FROM followees where user_id = ?"];
    sqlite3_bind_int(stmt, 1, user.userId);
    
    int success = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (success == SQLITE_ROW) {
        [self insertDB];
    }
}

- (void)deleteFromDB
{
    sqlite3_stmt* stmt = [DBConnection prepate:"DELETE FROM statuses WHERE id = ?"];

    sqlite3_bind_int64(stmt, 1, statusId);

    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    
    // ignore error
#if 0    
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }    
#endif
}

- (void)updateFavoriteState
{
    sqlite3_stmt* stmt = [DBConnection prepate:"UPDATE statuses SET favorited = ? WHERE id = ?"];
    sqlite3_bind_int(stmt, 1, favorited);
    sqlite3_bind_int64(stmt, 2, statusId);
    
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    // ignore error
#if 0
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }    
#endif
}

@end
