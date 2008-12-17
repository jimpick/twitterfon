#import "User.h"
#import "DBConnection.h"
#import "StringUtil.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt* user_by_id_statement = nil;

@implementation User

@synthesize userId;
@synthesize name;
@synthesize screenName;
@synthesize location;
@synthesize description;
@synthesize url;
@synthesize followersCount;
@synthesize profileImageUrl;
@synthesize protected;
@synthesize friendsCount;
@synthesize statusesCount;
@synthesize favoritesCount;
@synthesize following;
@synthesize notifications;

- (void)updateWithJSonDictionary:(NSDictionary*)dic
{
    [name release];
    [screenName release];
    [location release];
    [description release];
    [url release];
    [profileImageUrl release];
    
    userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [dic objectForKey:@"name"];
	screenName      = [dic objectForKey:@"screen_name"];
	location        = [dic objectForKey:@"location"];
	description     = [dic objectForKey:@"description"];
	url             = [dic objectForKey:@"url"];
    profileImageUrl = [dic objectForKey:@"profile_image_url"];

    followersCount  = ([dic objectForKey:@"followers_count"] == [NSNull null]) ? 0 : [[dic objectForKey:@"followers_count"] longValue];
    protected       = ([dic objectForKey:@"protected"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"protected"] boolValue];
    
    friendsCount    = ([dic objectForKey:@"friends_count"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"friends_count"] longValue];
    statusesCount   = ([dic objectForKey:@"statuses_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"statuses_count"] longValue];
    favoritesCount  = ([dic objectForKey:@"favourites_count"]  == [NSNull null]) ? 0 : [[dic objectForKey:@"favourites_count"] longValue];
    following       = ([dic objectForKey:@"following"]       == [NSNull null]) ? 0 : [[dic objectForKey:@"following"] boolValue];
    notifications   = ([dic objectForKey:@"notifications"]   == [NSNull null]) ? 0 : [[dic objectForKey:@"notifications"] boolValue];
    
    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)location == [NSNull null]) location = @"";
    if ((id)description == [NSNull null]) description = @"";
    if ((id)url == [NSNull null]) url = @"";
    if ((id)profileImageUrl == [NSNull null]) profileImageUrl = @"";
    
    [name retain];
    [screenName retain];
    location = [[location unescapeHTML] retain];
    description = [[description unescapeHTML] retain];
    [url retain];
    [profileImageUrl retain];
}

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    
    [self updateWithJSonDictionary:dic];
	
	return self;
}

- (User*)initWithSearchResult:(NSDictionary*)dic
{
	self = [super init];
	
	userId          = [[dic objectForKey:@"from_user_id"] longValue];
    
    name            = [dic objectForKey:@"from_user"];
	screenName      = [dic objectForKey:@"from_user"];
	location        = @"";
	url             = @"";
    followersCount  = 0;
    profileImageUrl = [dic objectForKey:@"profile_image_url"];
    protected       = false;
    description     = @"";
    
    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)profileImageUrl == [NSNull null]) profileImageUrl = @"";
    [name retain];
    [screenName retain];
    [profileImageUrl retain];
	
	return self;
}

+ (User*)userWithId:(int)id
{
    if (user_by_id_statement == nil) {
        user_by_id_statement = [DBConnection prepate:"SELECT * FROM users WHERE user_id = ?"];
    }
    
    sqlite3_bind_int64(user_by_id_statement, 1, id);
    int ret = sqlite3_step(user_by_id_statement);
    if (ret != SQLITE_ROW) {
        sqlite3_reset(user_by_id_statement);
        return nil;
    }
    
    User *user = [[[User alloc] init] autorelease];
    user.userId           = (uint32_t)sqlite3_column_int(user_by_id_statement, 0);
    user.name             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 1)];
    user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 2)];
    user.location         = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 3)];
    user.description      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 4)];
    user.url              = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 5)];
    user.followersCount   = (uint32_t)sqlite3_column_int(user_by_id_statement, 6);
    user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(user_by_id_statement, 7)];
    user.protected        = (uint32_t)sqlite3_column_int(user_by_id_statement, 8) ? true : false;

    sqlite3_reset(user_by_id_statement);
    return user;
}

- (id)copyWithZone:(NSZone *)zone
{
    User *dist = [[User allocWithZone:zone] init];
	dist.userId             = userId;
    dist.name               = name;
	dist.screenName         = screenName;
	dist.location           = location;
	dist.description        = description;
	dist.url                = url;
	dist.followersCount     = followersCount;
	dist.profileImageUrl    = profileImageUrl;
    dist.protected          = protected;
    
    return dist;
}

- (void)updateDB
{
    if (insert_statement == nil) {
        insert_statement = [DBConnection prepate:"REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"];
    }
    sqlite3_bind_int(insert_statement,  1, userId);
    sqlite3_bind_text(insert_statement, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [screenName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 4, [location UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 5, [description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 6, [url UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,  7, followersCount);
    sqlite3_bind_text(insert_statement, 8, [profileImageUrl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(insert_statement,  9, protected);

    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        [DBConnection assert];
    }
}

- (void)dealloc
{
    [url release];
    [location release];
    [description release];
    [name release];
    [screenName release];
    [profileImageUrl release];
   	[super dealloc];
}

@end
