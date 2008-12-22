#import "User.h"
#import "DBConnection.h"
#import "StringUtil.h"

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
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"SELECT * FROM users WHERE user_id = ?"];
        [stmt retain];
    }
    
    [stmt bindInt64:id forIndex:1];
    int ret = [stmt step];
    if (ret != SQLITE_ROW) {
        [stmt reset];
        return nil;
    }
    
    User *user = [[[User alloc] init] autorelease];
    user.userId           = [stmt getInt32:0];
    user.name             = [stmt getString:1];
    user.screenName       = [stmt getString:2];
    user.location         = [stmt getString:3];
    user.description      = [stmt getString:4];
    user.url              = [stmt getString:5];
    user.followersCount   = [stmt getInt32:6];
    user.profileImageUrl  = [stmt getString:7];
    user.protected        = [stmt getInt32:8] ? true : false;

    [stmt reset];
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
    static Statement *stmt = nil;
    if (stmt == nil) {
        stmt = [DBConnection statementWithQuery:"REPLACE INTO users VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"];
        [stmt retain];
    }
    [stmt bindInt32:userId              forIndex:1];
    [stmt bindString:name               forIndex:2];
    [stmt bindString:screenName         forIndex:3];
    [stmt bindString:location           forIndex:4];
    [stmt bindString:description        forIndex:5];
    [stmt bindString:url                forIndex:6];
    [stmt bindInt32:followersCount      forIndex:7];
    [stmt bindString:profileImageUrl    forIndex:8];
    [stmt bindInt32:protected           forIndex:9];

    if ([stmt step] == SQLITE_ERROR) {
        [DBConnection assert];
    }
    [stmt reset];
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
