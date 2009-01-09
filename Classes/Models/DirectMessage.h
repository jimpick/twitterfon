#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"
#import "Tweet.h"

@interface DirectMessage : Tweet
{
	User*           recipient;
    int             senderId;
    int             recipientId;
    NSString*       senderScreenName;
    NSString*       recipientScreenName;
}

@property (getter=tweetId, setter=setTweetId:) sqlite_int64     messageId;
@property (retain, getter=user, setter=setUser:) User*          sender;

@property (nonatomic, retain) User*         recipient;
@property (nonatomic, assign) int           senderId;
@property (nonatomic, assign) int           recipientId;
@property (nonatomic, retain) NSString*     senderScreenName;
@property (nonatomic, retain) NSString*     recipientScreenName;

+ (int)restore:(NSMutableArray*)array all:(BOOL)all;
+ (DirectMessage*)messageWithJsonDictionary:(NSDictionary*)dic;

+ (BOOL)isExists:(sqlite_int64)messageId;;
+ (sqlite_int64)lastSentMessageId;
+ (int)countMessages:(int)userId;

- (DirectMessage*)initWithJsonDictionary:(NSDictionary*)dic;

- (void)insertDB;
- (void)deleteFromDB;

- (int)getConversation:(NSMutableArray*)messages;


- (id)copyWithZone:(NSZone *)zone;
@end
