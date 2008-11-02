#import "User.h"
#import "DBConnection.h"

static sqlite3_stmt* select_statement = nil;
static sqlite3_stmt* insert_statement = nil;

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

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	
	userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [[dic objectForKey:@"name"] retain];
	screenName      = [[dic objectForKey:@"screen_name"] retain];
	location        = [[dic objectForKey:@"location"] retain];
//	description     = [[dic objectForKey:@"description"] retain];
	url             = [[dic objectForKey:@"url"] retain];
    followersCount  = [[dic objectForKey:@"followers_count"] longValue];
    profileImageUrl = [[dic objectForKey:@"profile_image_url"] retain];
    protected       = [[dic objectForKey:@"protected"] boolValue];
    description     = @"";

    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)location == [NSNull null]) location = @"";
//    if ((id)description == [NSNull null]) description = @"";
    if ((id)url == [NSNull null]) url = @"";
	
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

+ (User*)initWithDB:(sqlite3_stmt*)statement
{
    User *user = [[User alloc] init];
    user.userId           = (uint32_t)sqlite3_column_int(statement, 0);
    user.name             = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
    user.screenName       = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
    user.location         = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
    user.description      = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
    user.url              = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 5)];
    user.followersCount   = (uint32_t)sqlite3_column_int(statement, 6);
    user.profileImageUrl  = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)];
    user.protected        = (uint32_t)sqlite3_column_int(statement, 8) ? true : false;
    
    return user;
}

- (BOOL)isExists
{
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (select_statement== nil) {
        static char *sql = "SELECT user_id FROM users WHERE user_id=?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    
    sqlite3_bind_int64(select_statement, 1, userId);
    BOOL result = (sqlite3_step(select_statement) == SQLITE_ROW) ? true : false;
    sqlite3_reset(select_statement);
    return result;
}
- (void)insertDB
{
    if ([self isExists]) {
        return;
    }
    
    sqlite3* database = [DBConnection getSharedDatabase];
    
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
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
