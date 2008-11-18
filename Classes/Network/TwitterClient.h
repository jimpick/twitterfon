#import <UIKit/UIKit.h>
#import "TFConnection.h"
#import "Message.h"

typedef enum {
    TWITTER_REQUEST_TIMELINE,
    TWITTER_REQUEST_FAVORITE,
    TWITTER_REQUEST_DESTROY_FAVORITE,
    TWITTER_REQUEST_UPDATE,
    TWITTER_REQUEST_UPDATE_LOCATION,
    TWITTER_REQUEST_DESTROY_MESSAGE,
    TWITTER_REQUEST_SEARCH,
    TWITTER_REQUEST_TRENDS,
    TWITTER_REQUEST_USER,
    TWITTER_REQUEST_CREATE_FRIENDSHIP,
    TWITTER_REQUEST_DESTROY_FRIENDSHIP,
    TWITTER_REQUEST_FRIENDSHIP_EXISTS,
} RequestType;

@interface TwitterClient : TFConnection
{
    RequestType request;
    id          context;
    SEL         action;
}

@property(nonatomic, readonly) RequestType request;
@property(nonatomic, assign) id context;

- (id)initWithTarget:(id)delegate action:(SEL)action;

- (void)getTimeline:(MessageType)type params:(NSDictionary*)params;
- (void)getUserTimeline:(NSString*)screen_name params:(NSDictionary*)params;
- (void)getUser:(NSString*)screen_name;
- (void)post:(NSString*)tweet;
- (void)destroy:(Message*)message;
- (void)favorite:(Message*)message;
- (void)friendship:(NSString*)screen_name create:(BOOL)create;
- (void)search:(NSDictionary*)params;
- (void)existFriendship:(NSString*)screen_name;
- (void)updateLocation:(float)latitude longitude:(float)longitude;
- (void)trends;
- (void)verify;

@end
