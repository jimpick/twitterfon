#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "User.h"
#import "Tweet.h"

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
    
    CGRect          textBounds;
    CGFloat         cellHeight;
}

@property (nonatomic, assign) sqlite_int64  messageId;
@property (nonatomic, retain) User*         sender;
@property (nonatomic, retain) User*         recipient;
@property (nonatomic, assign) int           senderId;
@property (nonatomic, assign) int           recipientId;
@property (nonatomic, retain) NSString*     senderScreenName;
@property (nonatomic, retain) NSString*     recipientScreenName;
@property (nonatomic, retain) NSString*     senderProfileImageUrl;

+ (int)restore:(NSMutableArray*)array all:(BOOL)all;
+ (int)getConversation:(int)senderId messages:(NSMutableArray*)messages all:(BOOL)all;
+ (DirectMessage*)messageWithJsonDictionary:(NSDictionary*)dic;

+ (BOOL)isExists:(sqlite_int64)messageId;;

- (DirectMessage*)initWithJsonDictionary:(NSDictionary*)dic;

- (void)updateAttribute;

- (void)insertDB;
- (void)deleteFromDB;

- (id)copyWithZone:(NSZone *)zone;
@end
