#import "Status.h"
#import "Followee.h"
#import "DBConnection.h"
#import "REString.h"
#import "StringUtil.h"

@interface Status (Private)
- (void)insertDB;
@end

@implementation Status

@synthesize statusId;
@synthesize user;
@synthesize source;
@synthesize favorited;
@synthesize truncated;

@synthesize inReplyToStatusId;
@synthesize inReplyToUserId;
@synthesize inReplyToScreenName;

- (void)dealloc
{
    [inReplyToScreenName release];
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
        user = [User userWithJsonDictionary:userDic];
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
    
    user = [User userWithSearchResult:dic];
    
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
    Status *dist = [super copyWithZone:zone];
    
	dist.statusId  = statusId;
	dist.user      = user;
    dist.source     = source;
    dist.favorited  = favorited;
    dist.truncated  = truncated;

    dist.inReplyToStatusId   = inReplyToStatusId;
    dist.inReplyToUserId     = inReplyToUserId;
    dist.inReplyToScreenName = inReplyToScreenName;
    
    return dist;
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

    if (accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
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
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM statuses WHERE id = ?"];
        [stmt retain];
    }

    [stmt bindInt64:aStatusId forIndex:1];
    if ([stmt step] != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
    Status *s = [Status initWithStatement:stmt type:TWEET_TYPE_FRIENDS];
    [stmt reset];
    return s;
}

+ (Status*)initWithStatement:(Statement*)stmt type:(TweetType)type
{
    // sqlite3 statement should be:
    //  SELECT * FROM messsages
    //
    Status *s               = [[[Status alloc] init] autorelease];
    
    s.statusId              = [stmt getInt64:0];
    s.text                  = [stmt getString:3];
    s.createdAt             = [stmt getInt32:4];
    s.source                = [stmt getString:5];
    s.favorited             = [stmt getInt32:6];
    s.truncated             = [stmt getInt32:7];
    s.inReplyToStatusId     = [stmt getInt64:8];
    s.inReplyToUserId       = [stmt getInt32:9];
    s.inReplyToScreenName   = [stmt getString:10];
    
    s.user = [User userWithId:[stmt getInt32:2]];
    
    s.unread                = false;
    s.type                  = type;

    s.cellType = TWEET_CELL_TYPE_NORMAL;
    [s updateAttribute];
    
    return s;
}

+ (BOOL)isExists:(sqlite_int64)aStatusId type:(TweetType)aType
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT id FROM statuses WHERE id=? and type=?"];
        [stmt retain];
    }
    
    [stmt bindInt64:aStatusId forIndex:1];
    [stmt bindInt32:aType forIndex:2];
    
    BOOL result = ([stmt step] == SQLITE_ROW) ? true : false;
    [stmt reset];
    return result;
}

- (void)insertDB
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"INSERT INTO statuses VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    [stmt bindInt64:statusId    forIndex:1];
    [stmt bindInt32:type        forIndex:2];
    [stmt bindInt32:user.userId forIndex:3];
    
    [stmt bindString:text       forIndex:4];
    [stmt bindInt32:createdAt   forIndex:5];
    [stmt bindString:source     forIndex:6];
    [stmt bindInt32:favorited   forIndex:7];
    [stmt bindInt32:truncated   forIndex:8];
    
    [stmt bindInt64:inReplyToStatusId    forIndex:9];
    [stmt bindInt32:inReplyToUserId      forIndex:10];
    [stmt bindString:inReplyToScreenName forIndex:11];
    
    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection alert];
    }
    [stmt reset];
    
    [user updateDB];

    if (type == TWEET_TYPE_FRIENDS) {
        [Followee insertDB:user];
    }
}

- (void)insertDBIfFollowing
{
    Statement *stmt = [DBConnection statementWithQuery:"SELECT user_id FROM followees where user_id = ?"];
    [stmt bindInt32:user.userId forIndex:1];
    if ([stmt step] == SQLITE_ROW) {
        [self insertDB];
    }
}

- (void)deleteFromDB
{
    Statement *stmt = [DBConnection statementWithQuery:"DELETE FROM statuses WHERE id = ?"];
    [stmt bindInt64:statusId forIndex:1];
    [stmt step]; // ignore error
}

- (void)updateFavoriteState
{
    Statement *stmt = [DBConnection statementWithQuery:"UPDATE statuses SET favorited = ? WHERE id = ?"];
    [stmt bindInt32:favorited forIndex:1];
    [stmt bindInt64:statusId forIndex:2];
    [stmt step]; // ignore error
}

@end
