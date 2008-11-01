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
    BOOL        protected;
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

- (User*)initWithJsonDictionary:(NSDictionary*)dic;
- (User*)initWithSearchResult:(NSDictionary*)dic;
- (id)copyWithZone:(NSZone *)zone;

- (void)insertDB;

@end
