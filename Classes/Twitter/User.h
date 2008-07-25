#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface User : NSObject
{
	uint32_t    userId;
	NSString*   screenName;
	NSString*   profileImageUrl;
}

@property (nonatomic, assign) uint32_t  userId;
@property (nonatomic, copy)   NSString* screenName;
@property (nonatomic, copy)   NSString* profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;

@end
