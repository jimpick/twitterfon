#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface User : NSObject
{
	uint32_t    userId;
    NSString*   name;
	NSString*   screenName;
	NSString*   location;
	NSString*   description;
	NSString*   url;
	uint32_t    followersCount;
	NSString*   profileImageUrl;
}

@property (nonatomic, assign) uint32_t  userId;
@property (nonatomic, copy)   NSString* name;
@property (nonatomic, copy)   NSString* screenName;
@property (nonatomic, copy)   NSString* location;
@property (nonatomic, copy)   NSString* description;
@property (nonatomic, copy)   NSString* url;
@property (nonatomic, assign) uint32_t  followersCount;
@property (nonatomic, copy)   NSString* profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;

@end
