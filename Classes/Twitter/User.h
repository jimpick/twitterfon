#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface User : NSObject
{
	long        userId;
	NSString*   screenName;
	NSString*   profileImageUrl;
}

@property (nonatomic, assign) long      userId;
@property (nonatomic, assign) NSString*   screenName;
@property (nonatomic, assign) NSString*   profileImageUrl;

- (User*)initWithJsonDictionary:(NSDictionary*)dic;

@end
