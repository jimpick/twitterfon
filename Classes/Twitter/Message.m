#import "Message.h"

@implementation Message

@synthesize messageId;
@synthesize text;
@synthesize createdAt;
@synthesize inReplyToStatusId;
@synthesize inReplyToUserId;
@synthesize source;
@synthesize favorited;
@synthesize truncated;
@synthesize user;

- (Message*)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
	messageId = [[dic objectForKey:@"id"] longValue];
	text = [[dic objectForKey:@"text"] copy];
    createdAt = [[dic objectForKey:@"created_at"] copy];
	source = [[dic objectForKey:@"source"] copy];
	//favorited = [[dic objectForKey:@"favorited"] longValue] != 0;
	//truncated = [[dic objectForKey:@"truncated"] longValue] != 0;
	
	NSNumber* n;
	n = [dic objectForKey:@"in_reply_to_status_id"];
	if (![n isKindOfClass:[NSNull class]]) inReplyToStatusId = [n longValue];
	n = [dic objectForKey:@"in_reply_to_user_id"];
	if (![n isKindOfClass:[NSNull class]]) inReplyToUserId = [n longValue];
	
	NSDictionary* userDic = [dic objectForKey:@"user"];
	if (userDic) {
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    else {
        userDic = [dic objectForKey:@"sender"];
        user = [[User alloc] initWithJsonDictionary:userDic];
    }
    

	return self;
}

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic
{
	return [[[Message alloc] initWithJsonDictionary:dic] autorelease];
}

@end
