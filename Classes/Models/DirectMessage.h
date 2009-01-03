#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"
#import "Tweet.h"

#define MAX_BUBBLE_WIDTH (320 - 32 - 8 - 20 - 20)
#define MAX_TEXT_WIDTH   (MAX_BUBBLE_WIDTH - 30)
#define TIMESTAMP_DIFF   (60 * 30)

#define NUM_MESSAGE_PER_PAGE    40

@interface DirectMessage : Tweet
{
    sqlite_int64    messageId;
	User*           sender;
	User*           recipient;
    int             senderId;
    int             recipientId;
    NSString*       senderScreenName;
    NSString*       recipientScreenName;
    NSString*       senderProfileImageUrl;

    CGRect          textRect;
    BOOL            needTimestamp;
}

@property (nonatomic, assign) sqlite_int64  messageId;
@property (nonatomic, retain) User*         sender;
@property (nonatomic, retain) User*         recipient;
@property (nonatomic, assign) int           senderId;
@property (nonatomic, assign) int           recipientId;
@property (nonatomic, retain) NSString*     senderScreenName;
@property (nonatomic, retain) NSString*     recipientScreenName;
@property (nonatomic, retain) NSString*     senderProfileImageUrl;

@property (nonatomic, assign) CGRect        textRect;
@property (nonatomic, assign) BOOL          needTimestamp;

+ (int)restore:(NSMutableArray*)array all:(BOOL)all;
+ (int)getConversation:(int)senderId messages:(NSMutableArray*)messages;
+ (DirectMessage*)messageWithJsonDictionary:(NSDictionary*)dic;

+ (BOOL)isExists:(sqlite_int64)messageId;;
+ (sqlite_int64)lastSentMessageId;
+ (int)countMessages:(int)userId;

- (DirectMessage*)initWithJsonDictionary:(NSDictionary*)dic;

- (void)updateAttribute;
- (void)loadUserObject;
- (void)insertDB;
- (void)deleteFromDB;

- (id)copyWithZone:(NSZone *)zone;
@end
