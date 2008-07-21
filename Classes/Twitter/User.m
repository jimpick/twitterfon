#import "User.h"

@implementation User

@synthesize userId;
@synthesize screenName;
@synthesize profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	
	userId          = [[dic objectForKey:@"id"] longValue];
	screenName      = [[dic objectForKey:@"screen_name"] copy];
	profileImageUrl = [[dic objectForKey:@"profile_image_url"] copy];
	
	return self;
}

- (void)dealloc
{
    [screenName release];
    [profileImageUrl release];
   	[super dealloc];
}

@end
