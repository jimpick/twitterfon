#import <UIKit/UIKit.h>
#import "User.h"
#import "sqlite3.h"

#define NUM_MESSAGE_PER_PAGE    40

typedef enum {
    TWEET_TYPE_FRIENDS = 0,
    TWEET_TYPE_REPLIES,
    TWEET_TYPE_MESSAGES,
    TWEET_TYPE_SENT,
    TWEET_TYPE_SEARCH_RESULT,
    TWEET_TYPE_FAVORITES,
} TweetType;

typedef enum {
    TWEET_CELL_TYPE_NORMAL,
    TWEET_CELL_TYPE_USER,
    TWEET_CELL_TYPE_DETAIL,
} TweetCellType;

@interface Tweet : NSObject
{
    sqlite_int64    tweetId;
	NSString*       text;
    User*           user;
    
    NSString*       stringOfCreatedAt;
    time_t          createdAt;
    NSString*       timestamp;
    BOOL            needTimestamp;

    BOOL            unread;
    BOOL            hasReply;
    TweetType       type;
    TweetCellType   cellType;
    
    CGRect          textBounds;
    CGFloat         cellHeight;    
    
    UITableViewCellAccessoryType accessoryType;
}

@property (nonatomic, assign) sqlite_int64      tweetId;
@property (nonatomic, retain) NSString*         text;
@property (nonatomic, retain) User*             user;

@property (nonatomic, assign) time_t            createdAt;
@property (nonatomic, retain) NSString*         timestamp;
@property (nonatomic, assign) BOOL          needTimestamp;

@property (nonatomic, assign) BOOL              unread;
@property (nonatomic, assign) BOOL              hasReply;
@property (nonatomic, assign) TweetType         type;
@property (nonatomic, assign) TweetCellType     cellType;

@property (nonatomic, assign) CGFloat       cellHeight;
@property (nonatomic, assign) CGRect        textBounds;

@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;


- (int)getConversation:(NSMutableArray*)messages;

- (NSString*)timestamp;
- (void)updateAttribute;
- (void)calcTextBounds:(int)textWidth;
- (BOOL)hasConversation;

- (id)copyWithZone:(NSZone*)zone;

@end
