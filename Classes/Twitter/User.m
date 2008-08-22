#import "User.h"

@implementation User

@synthesize userId;
@synthesize name;
@synthesize screenName;
@synthesize location;
@synthesize description;
@synthesize url;
@synthesize followersCount;
@synthesize profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	
	userId          = [[dic objectForKey:@"id"] longValue];
    
    name            = [[dic objectForKey:@"name"] copy];
	screenName      = [[dic objectForKey:@"screen_name"] copy];
	location        = [[dic objectForKey:@"location"] copy];
	description     = [[dic objectForKey:@"description"] copy];
	url             = [[dic objectForKey:@"url"] copy];
    followersCount  = [[dic objectForKey:@"followers_count"] longValue];
    profileImageUrl = [[dic objectForKey:@"profile_image_url"] copy];

    if ((id)name == [NSNull null]) name = @"";
    if ((id)screenName == [NSNull null]) screenName = @"";
    if ((id)location == [NSNull null]) location = @"";
    if ((id)description == [NSNull null]) description = @"";
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
