#import <UIKit/UIKit.h>
#import "User.h"
#import "sqlite3.h"

typedef enum {
    TWEET_TYPE_FRIENDS = 0,
    TWEET_TYPE_REPLIES,
    TWEET_TYPE_MESSAGES,
    TWEET_TYPE_SENT,
    TWEET_TYPE_SEARCH_RESULT,
} TweetType;

typedef enum {
    TWEET_CELL_TYPE_NORMAL,
    TWEET_CELL_TYPE_USER,
    TWEET_CELL_TYPE_DETAIL,
} TweetCellType;

@interface Tweet : NSObject
{
	NSString*       text;
    
    NSString*       stringOfCreatedAt;
    time_t          createdAt;
    NSString*       timestamp;

    BOOL            unread;
    BOOL            hasReply;
    TweetType       type;
    TweetCellType   cellType;
    
    UITableViewCellAccessoryType accessoryType;
}

@property (nonatomic, retain) NSString*         text;
@property (nonatomic, assign) time_t            createdAt;
@property (nonatomic, retain) NSString*         timestamp;

@property (nonatomic, assign) BOOL              unread;
@property (nonatomic, assign) BOOL              hasReply;
@property (nonatomic, assign) TweetType         type;
@property (nonatomic, assign) TweetCellType     cellType;

@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;

- (NSString*)timestamp;
- (void)updateAttribute;
- (void)copyWithZone:(Tweet *)dist;

@end
