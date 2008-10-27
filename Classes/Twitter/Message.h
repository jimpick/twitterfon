#import <UIKit/UIKit.h>
#import "User.h"
#import "sqlite3.h"

typedef enum {
    MSG_TYPE_LOAD_USERTIMELINE = -3,
    MSG_TYPE_LOAD_FROM_DB  = -2,
    MSG_TYPE_LOAD_FROM_WEB = -1,
    MSG_TYPE_FRIENDS = 0,
    MSG_TYPE_REPLIES,
    MSG_TYPE_MESSAGES,
    MSG_TYPE_USER,
    MSG_TYPE_SEARCH_RESULT,
} MessageType;

#define IMAGE_PADDING       10
#define H_MARGIN            10
#define INDICATOR_WIDTH     24
#define DETAIL_BUTTON_WIDTH 41

#define DETAIL_BUTTON_USER  (DETAIL_BUTTON_WIDTH - H_MARGIN)
#define DETAIL_BUTTON_OTHER (DETAIL_BUTTON_WIDTH - INDICATOR_WIDTH) 

#define IMAGE_WIDTH         48
#define USER_CELL_PADDING   10
#define USER_CELL_LEFT      42

#define TOP                 16
#define LEFT                (IMAGE_PADDING * 2 + IMAGE_WIDTH)
#define CELL_WIDTH          (320 - INDICATOR_WIDTH - LEFT)
#define TIMESTAMP_WIDTH     60
#define TIMESTAMP_LEFT      (LEFT + CELL_WIDTH) - TIMESTAMP_WIDTH

#define USER_CELL_WIDTH     (320 - (USER_CELL_LEFT + USER_CELL_PADDING * 2))

@interface Message : NSObject
{
	sqlite_int64    messageId;
	User*           user;
	NSString*       text;
    NSString*       stringOfCreatedAt;
    time_t          createdAt;
    NSString*       source;
    BOOL            favorited;
    NSString*       timestamp;

    BOOL            unread;
    BOOL            hasReply;
    MessageType     type;
    CGRect          textBounds;
    CGFloat         cellHeight;
    int             textHeight;
   
    int             page;
    
    UITableViewCellAccessoryType accessoryType;
}

@property (nonatomic, assign) sqlite_int64  messageId;
@property (nonatomic, assign) User*         user;
@property (nonatomic, retain) NSString*     text;
@property (nonatomic, assign) time_t        createdAt;
@property (nonatomic, retain) NSString*     source;
@property (nonatomic, assign) BOOL          favorited;
@property (nonatomic, retain) NSString*     timestamp;

@property (nonatomic, assign) BOOL          unread;
@property (nonatomic, assign) MessageType   type;
@property (nonatomic, assign) BOOL          hasReply;
@property (nonatomic, assign) CGRect        textBounds;
@property (nonatomic, assign) CGFloat       cellHeight;
@property (nonatomic, assign) int           textHeight;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

@property (nonatomic, assign) int           page;

+ (Message*)messageWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;
+ (Message*)messageWithSearchResult:(NSDictionary*)dic;
+ (Message*)messageWithLoadMessage:(MessageType)type page:(int)page;
+ (Message*)initWithDB:(sqlite3_stmt*)statement type:(MessageType)type;
+ (BOOL)isExist:(sqlite_int64)aMessageId type:(MessageType)aType;
+ (void)calcTextBounds:(Message*)message textWidth:(int)textWidth;

- (Message*)initWithJsonDictionary:(NSDictionary*)dic type:(MessageType)type;
- (Message*)initWithSearchResult:(NSDictionary*)dic;
- (void)updateAttribute;

- (void)deleteFromDB;
- (void)updateFavoriteState;

- (id)copyWithZone:(NSZone *)zone;
@end
