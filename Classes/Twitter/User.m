#import "User.h"
#import "DBConnection.h"
#import "StringUtil.h"

sqlite3_stmt *insert_statement = nil;

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
    userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [[dic objectForKey:@"name"] retain];
	screenName      = [[dic objectForKey:@"screen_name"] retain];
	location        = [[dic objectForKey:@"location"] retain];
	description     = [[dic objectForKey:@"description"] retain];
	url             = [[dic objectForKey:@"url"] retain];
    profileImageUrl = [[dic objectForKey:@"profile_image_url"] retain];

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
    
    self.location    = [location unescapeHTML];
    self.description = [description unescapeHTML];
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
    
    name            = [[dic objectForKey:@"from_user"] retain];
	screenName      = [[dic objectForKey:@"from_user"] retain];
	location        = @"";
	url             = @"";
    followersCount  = 0;
    profileImageUrl = [[dic objectForKey:@"profile_image_url"] retain];
    protected       = false;
    description     = @"";
    
    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)url == [NSNull null]) url = @"";
	
	return self;
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
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (insert_statement == nil) {
        static char *sql = "REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
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
        NSAssert2(0, @"Error: failed to execute SQL command in %@ with message '%s'.", NSStringFromSelector(_cmd), sqlite3_errmsg(database));
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
