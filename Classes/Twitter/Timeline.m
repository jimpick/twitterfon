#import "Timeline.h"
#import "JSON.h"
#import "Message.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

@interface NSObject (TimelineDelegate)
- (void)timelineDidReceiveNewMessage:(Message*)msg;
- (void)timelineDidUpdate:(int)count insertAt:(int)position;
@end

@implementation Timeline

#define MAX_ROW_COUNT   200

@synthesize messages;

- (id)initWithDelegate:(id)aDelegate
{
	self = [super init];
	messages = [[NSMutableArray array] retain];
    delegate = aDelegate;
	return self;
}

- (void)dealloc
{
    [self cancel];
    [lastMessageDate release];
	[messages release];
	[super dealloc];
}

- (void)cancel
{
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (int)countMessages
{
    return [messages count];
}

- (Message*)messageAtIndex:(int)i
{
    return [messages objectAtIndex:i];
}

- (void)insertMessage:(Message*)m
{
    [messages insertObject:m atIndex:0];
}

- (void)update:(MessageType)aType userId:(int)user_id {
	if (twitterClient) return;
    
    type = aType;
    insertPosition = 0;

	twitterClient = [[TwitterClient alloc] initWithDelegate:self];
	[twitterClient get:type since:nil userId:user_id];
}

- (void)update:(MessageType)aType
{
	if (twitterClient) return;
    
    type = aType;
    insertPosition = 0;
    
	twitterClient = [[TwitterClient alloc] initWithDelegate:self];

    lastMessageDate = nil;
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    for (int i = 0; i < [messages count]; ++i) {
        Message *m = [messages objectAtIndex:i];
        if ([m.user.screenName compare:username] != NSOrderedSame) {
            lastMessageDate = [((Message*)[messages objectAtIndex:i]).createdAt copy];
            break;
        }
    }
	[twitterClient get:type since:lastMessageDate userId:0];
}

- (void)update:(MessageType)aType page:(int)aPage insertAt:(int)pos
{
	if (twitterClient) return;
	twitterClient = [[TwitterClient alloc] initWithDelegate:self];
    
    insertPosition = pos;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (aPage) {
        [param setObject:[NSString stringWithFormat:@"%d", aPage] forKey:@"page"];
    }

    if (lastMessageDate) {
        struct tm time;
        char timestr[128];
        setenv("TZ", "GMT", 1);
        strptime([lastMessageDate UTF8String], "%a %b %d %H:%M:%S %z %Y", &time);
        strftime(timestr, 128, "%a, %d %b %Y %H:%M:%S GMT", &time);
        [param setObject:[NSString stringWithUTF8String:timestr] forKey:@"since"];
    }
    [twitterClient get:type params:param];
}

- (int)restore:(MessageType)aType
{
    if ([messages count]) {
        [messages removeLastObject];
    }
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement == nil) {
        static char *sql = "SELECT * FROM messages WHERE type = ? order BY id DESC LIMIT 20 OFFSET ?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }    

    sqlite3_bind_int(select_statement, 1, aType);
    sqlite3_bind_int(select_statement, 2, [messages count]);
    int count = 0;
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Message *m = [Message initWithDB:select_statement type:aType];
        [messages addObject:m];
        ++count;
    }
    sqlite3_reset(select_statement);
    
    // Add "Load more 20 messages" cell
    if (count == 20) {
        [messages addObject:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_DB page:0]];
    }
    return count;
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

    // Add messages to the timeline
    int unread = 0;
    for (int i = [ary count] - 1; i >= 0; --i) {
        sqlite_int64 messageId = [[[ary objectAtIndex:i] objectForKey:@"id"] longLongValue];
        if (![Message isExist:messageId type:type]) {
            Message* m = [Message messageWithJsonDictionary:[ary objectAtIndex:i] type:type];
            m.unread = true;
            
            [messages insertObject:m atIndex:insertPosition];
            ++unread;
				
            if ([delegate respondsToSelector:@selector(timelineDidReceiveNewMessage:)]) {
                [delegate timelineDidReceiveNewMessage:m];
            }
		}
    }

    if (unread == 20) {
        if ([messages count] > insertPosition + unread) {
            Message *m = [messages objectAtIndex:insertPosition + unread];
            if (m.type <= MSG_TYPE_LOAD_FROM_WEB) {
                m.page += 1;
            }
            else {
                [messages insertObject:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_WEB page:2] atIndex:unread];
            }
        }
        else {
            [messages insertObject:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_WEB page:2] atIndex:unread];
        }
    }
    else {
        if (insertPosition) {
            [messages removeObjectAtIndex:insertPosition + unread];
        }
    }
	
    if (delegate && [delegate respondsToSelector:@selector(timelineDidUpdate:insertAt:)]) {
        [delegate timelineDidUpdate:unread insertAt:insertPosition];
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
