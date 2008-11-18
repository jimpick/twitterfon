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
    uint32_t    friendsCount;
    uint32_t    statusesCount;
    BOOL        notifications;
    BOOL        protected;
    BOOL        following;
}

@property (nonatomic, assign) uint32_t  userId;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* screenName;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, assign) uint32_t  followersCount;
@property (nonatomic, retain) NSString* profileImageUrl;
@property (nonatomic, assign) BOOL      protected;
@property (nonatomic, assign) uint32_t  friendsCount;
@property (nonatomic, assign) uint32_t  statusesCount;
@property (nonatomic, assign) BOOL      following;
@property (nonatomic, assign) BOOL      notifications;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;
- (User*)initWithSearchResult:(NSDictionary*)dic;
- (void)updateWithJSonDictionary:(NSDictionary*)dic;
- (id)copyWithZone:(NSZone *)zone;

@end
