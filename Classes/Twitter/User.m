#import "User.h"

@implementation User

@synthesize userId;
@synthesize screenName;
@synthesize name;
@synthesize url;
@synthesize location;
@synthesize description;
@synthesize followersCount;
@synthesize isProtected;
@synthesize profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	
	userId = [[dic objectForKey:@"id"] longValue];
	screenName = [[dic objectForKey:@"screen_name"] copy];
	name = [[dic objectForKey:@"name"] copy];
	url = [[dic objectForKey:@"url"] copy];
	location = [[dic objectForKey:@"location"] copy];
	description = [[dic objectForKey:@"description"] copy];
	followersCount = [[dic objectForKey:@"followers_count"] longValue];
	isProtected = [[dic objectForKey:@"protected"] longValue] != 0;
	profileImageUrl = [[dic objectForKey:@"profile_image_url"] copy];
	
	return self;
}

@end
