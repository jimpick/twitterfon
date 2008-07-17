#import <UIKit/UIKit.h>
#import "User.h"

@interface Message : NSObject
{
	long messageId;
	NSString* text;
	NSString* createdAt;
	long inReplyToStatusId;
	long inReplyToUserId;
	NSString* source;
	BOOL favorited;
	BOOL truncated;
	User* user;
}

@property (nonatomic, readonly) long messageId;
@property (nonatomic, readonly) NSString* text;
@property (nonatomic, readonly) NSString* createdAt;
@property (nonatomic, readonly) long inReplyToStatusId;
@property (nonatomic, readonly) long inReplyToUserId;
@property (nonatomic, readonly) NSString* source;
@property (nonatomic, readonly) BOOL favorited;
@property (nonatomic, readonly) BOOL truncated;
@property (nonatomic, readonly) User* user;

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic;
- (Message*)initWithJsonDictionary:(NSDictionary*)dic;

@end
