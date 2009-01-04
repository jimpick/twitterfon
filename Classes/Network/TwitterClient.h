#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Status.h"

typedef enum {
    TWITTER_REQUEST_TIMELINE,
    TWITTER_REQUEST_REPLIES,
    TWITTER_REQUEST_MESSAGES,
    TWITTER_REQUEST_SENT,
    TWITTER_REQUEST_FAVORITE,
    TWITTER_REQUEST_DESTROY_FAVORITE,
    TWITTER_REQUEST_CREATE_FRIENDSHIP,
    TWITTER_REQUEST_DESTROY_FRIENDSHIP,
    TWITTER_REQUEST_FRIENDSHIP_EXISTS,
} RequestType;

@interface TwitterClient : TFConnection
{
    RequestType request;
    id          context;
    SEL         action;
    BOOL        hasError;
    NSString*   errorMessage;
    NSString*   errorDetail;
}

@property(nonatomic, readonly) RequestType request;
@property(nonatomic, assign) id context;
@property(nonatomic, assign) BOOL hasError;
@property(nonatomic, copy) NSString* errorMessage;
@property(nonatomic, copy) NSString* errorDetail;

- (id)initWithTarget:(id)delegate action:(SEL)action;

- (void)getTimeline:(TweetType)type params:(NSDictionary*)params;
- (void)getUserTimeline:(NSString*)screen_name params:(NSDictionary*)params;
- (void)getUser:(NSString*)screen_name;
- (void)getMessage:(sqlite_int64)statusId;
- (void)post:(NSString*)tweet inReplyTo:(sqlite_int64)statusId;
- (void)send:(NSString*)text to:(NSString*)screen_name;
- (void)getFriends:(NSString*)screen_name page:(int)page isFollowers:(BOOL)isFollowers;
- (void)destroy:(Tweet*)tweet;
- (void)favorites:(NSString*)screenName page:(int)page;
- (void)toggleFavorite:(Status*)status;
- (void)friendship:(NSString*)screen_name create:(BOOL)create;
- (void)search:(NSString*)query;
- (void)existFriendship:(NSString*)screen_name;
- (void)updateLocation:(float)latitude longitude:(float)longitude;
- (void)trends;
- (void)verify;

- (void)alert;

@end
