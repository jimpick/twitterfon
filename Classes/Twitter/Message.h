#import <UIKit/UIKit.h>
#import "User.h"
#import "sqlite3.h"

typedef enum {
    MSG_TYPE_FRIENDS = 0,
    MSG_TYPE_REPLIES,
    MSG_TYPE_MESSAGES,
    MSG_TYPE_USER,
} MessageType;

#define IMAGE_PADDING       10
#define H_MARGIN            10
#define INDICATOR_WIDTH     24
#define DETAIL_BUTTON_WIDTH 41

#define DETAIL_BUTTON_USER  (DETAIL_BUTTON_WIDTH - H_MARGIN)
#define DETAIL_BUTTON_OTHER (DETAIL_BUTTON_WIDTH - INDICATOR_WIDTH) 

#define IMAGE_WIDTH         48
#define USER_CELL_PADDING   10

#define TOP                 16
#define LEFT                (IMAGE_PADDING * 2 + IMAGE_WIDTH)
#define CELL_WIDTH          (320 - INDICATOR_WIDTH - LEFT)
#define TIMESTAMP_WIDTH     60
#define TIMESTAMP_LEFT      (LEFT + CELL_WIDTH) - TIMESTAMP_WIDTH

#define USER_CELL_WIDTH     (320 - USER_CELL_PADDING * 2)

@interface Message : NSObject
{
	sqlite_int64    messageId;
	User*           user;
	NSString*       text;
    NSString*       createdAt;
    NSString*       source;
    BOOL            favorited;
    NSString*       timestamp;

    BOOL            unread;
    BOOL            hasReply;
    MessageType     type;
    CGRect          textBounds;
    CGFloat         cellHeight;
    
    UITableViewCellAccessoryType accessoryType;
}

@property (nonatomic, assign) sqlite_int64  messageId;
@property (nonatomic, assign) User*         user;
@property (nonatomic, copy)   NSString*     text;
@property (nonatomic, copy)   NSString*     createdAt;
@property (nonatomic, copy)   NSString*     source;
@property (nonatomic, assign) BOOL          favorited;
@property (nonatomic, copy)   NSString*     timestamp;

@property (nonatomic, assign) BOOL          unread;
@property (nonatomic, assign) MessageType   type;
@property (nonatomic, assign) BOOL          hasReply;
@property (nonatomic, assign) CGRect        textBounds;
@property (nonatomic, assign) CGFloat       cellHeight;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;
+ (Message*)initWithDB:(sqlite3_stmt*)statement type:(MessageType)type;
+ (BOOL)isExist:(sqlite_int64)aMessageId type:(MessageType)aType;

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;
- (void)updateAttribute;

- (id)copyWithZone:(NSZone *)zone;
@end
