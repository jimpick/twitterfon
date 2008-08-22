#import "Timeline.h"
#import "JSON.h"
#import "Message.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

@interface NSObject (TimelineDelegate)
- (void)timelineDidReceiveNewMessage:(Message*)msg;
- (void)timelineDidUpdate:(int)count;
@end

@implementation Timeline

@synthesize messages;
@synthesize delegate;

- (id)init
{
	self = [super init];
	messages = [[NSMutableArray array] retain];
	return self;
}

- (void)dealloc
{
	[messages release];
	[twitterClient release];
	[super dealloc];
}

- (int)countMessages
{
	return [messages count];
}

- (Message*)messageAtIndex:(int)i
{
	return [messages objectAtIndex:[messages count] - i - 1];
}

- (void)insertMessage:(Message*)m
{
    [messages addObject:m];
}

- (void)update:(MessageType)aType userId:(int)user_id {
	if (twitterClient) return;
    
    type = aType;

	twitterClient = [[TwitterClient alloc] initWithDelegate:self];
	[twitterClient get:type since:nil userId:user_id];
}

- (void)update:(MessageType)aType
{
	if (twitterClient) return;
    
    type = aType;

	twitterClient = [[TwitterClient alloc] initWithDelegate:self];

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString* lastMessageDate = nil;
    for (int i = [messages count] -1; i >= 0; --i) {
        Message *m = [messages objectAtIndex:i];
        if ([m.user.screenName compare:username] != NSOrderedSame) {
            lastMessageDate = ((Message*)[messages objectAtIndex:i]).createdAt;
            break;
        }
    }
	[twitterClient get:type since:lastMessageDate userId:0];
}

- (void)restore:(MessageType)aType
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement== nil) {
        static char *sql = "SELECT * FROM messages WHERE type = ? order BY id limit 40";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }    

    sqlite3_bind_int(select_statement, 1, aType);
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Message *m = [Message initWithDB:select_statement type:aType];
        [messages addObject:m];
    }
    sqlite3_reset(select_statement);
  
}

- (void)twitterClientDidSucceed:(TwitterClient*)sender messages:(NSObject*)obj
{
	[twitterClient autorelease];
	twitterClient = nil;

    if (obj == nil) return;
    
    NSArray *ary = nil;
    if ([obj isKindOfClass:[NSArray class]]) {
        ary = (NSArray*)obj;
    }
    else {
        return;
    }

    int unread = 0;
    for (int i = [ary count]-1; i >= 0; --i) {
        sqlite_int64 messageId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
        if (![Message isExist:messageId type:type]) {
            Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:type];
            m.unread = true;
                
            [messages addObject:m];
            ++unread;
				
            if ([delegate respondsToSelector:@selector(timelineDidReceiveNewMessage:)]) {
                [delegate timelineDidReceiveNewMessage:m];
            }
		}
    }
	
    if (delegate && unread && [delegate respondsToSelector:@selector(timelineDidUpdate:)]) {
        [delegate timelineDidUpdate:unread];
	}
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error
                                                    message:detail
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];	
    [alert release];
    
	[twitterClient autorelease];
	twitterClient = nil;
}

@end
