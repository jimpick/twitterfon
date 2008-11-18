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

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	
	userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [[dic objectForKey:@"name"] retain];
	screenName      = [[dic objectForKey:@"screen_name"] retain];
	location        = [[dic objectForKey:@"location"] retain];
	description     = [[dic objectForKey:@"description"] retain];
	url             = [[dic objectForKey:@"url"] retain];
    followersCount  = [[dic objectForKey:@"followers_count"] longValue];
    profileImageUrl = [[dic objectForKey:@"profile_image_url"] retain];
    protected       = [[dic objectForKey:@"protected"] boolValue];

    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)location == [NSNull null]) location = @"";
    if ((id)description == [NSNull null]) description = @"";
    if ((id)url == [NSNull null]) url = @"";
    
    self.location    = [location unescapeHTML];
    self.description = [description unescapeHTML];
	
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
