#import <UIKit/UIKit.h>
#import "User.h"
#import "sqlite3.h"

typedef enum {
    MSG_TYPE_FRIENDS = 0,
    MSG_TYPE_REPLIES,
    MSG_TYPE_MESSAGES,
} MessageType;

@interface Message : NSObject
{
	long        messageId;
	NSString*   text;
	User*       user;
    BOOL        unread;
}

@property (nonatomic, assign) long messageId;
@property (nonatomic, assign) NSString* text;
@property (nonatomic, assign) User* user;
@property (nonatomic, assign) BOOL unread;

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;
- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;

@end
