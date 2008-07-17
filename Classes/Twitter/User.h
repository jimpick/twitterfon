#import <UIKit/UIKit.h>

@interface User : NSObject
{
	long userId;
	NSString* screenName;
	NSString* name;
	NSString* url;
	NSString* location;
	NSString* description;
	long followersCount;
	BOOL isProtected;
	NSString* profileImageUrl;
}

@property (nonatomic, readonly) long userId;
@property (nonatomic, readonly) NSString* screenName;
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSString* url;
@property (nonatomic, readonly) NSString* location;
@property (nonatomic, readonly) NSString* description;
@property (nonatomic, readonly) long followersCount;
@property (nonatomic, readonly) BOOL isProtected;
@property (nonatomic, readonly) NSString* profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;

@end
