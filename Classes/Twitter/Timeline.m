#import "Timeline.h"
#import "JSON.h"
#import "Message.h"
#import "TimeUtils.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

@interface NSObject (TimelineDelegate)
- (void)timelineDidReceiveNewMessage:(Message*)msg;
- (void)timelineDidUpdate:(int)count insertAt:(int)position;
- (void)timelineDidFailToUpdate;
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

- (void)getUserTimeline:(int)user_id page:(int)aPage insertAt:(int)pos
{
	if (twitterClient) return;
    
    type = MSG_TYPE_USER;
    if (aPage < 1) aPage = 1;
    page = aPage;
    insertPosition = pos;
    since_id = 0;

	twitterClient = [[TwitterClient alloc] initWithDelegate:self];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", user_id] forKey:@"id"];
    if (page >= 2) {
        [param setObject:[NSString stringWithFormat:@"%d", aPage] forKey:@"page"];
    }
	[twitterClient get:type params:param];
}

- (void)getTimeline:(MessageType)aType page:(int)aPage insertAt:(int)pos
{
	if (twitterClient) return;
	twitterClient = [[TwitterClient alloc] initWithDelegate:self];
    
    type = aType;
    page = aPage;
    insertPosition = pos;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (aPage == 1) {
        since_id = 0;
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        for (int i = 0; i < [messages count]; ++i) {
            Message *m = [messages objectAtIndex:i];
            if ([m.user.screenName compare:username] != NSOrderedSame) {
                since_id = ((Message*)[messages objectAtIndex:i]).messageId;
                break;
            }
        }

        if (since_id) {
            [param setObject:[NSString stringWithFormat:@"%d", since_id] forKey:@"since_id"];
            [param setObject:@"200" forKey:@"count"];
        }
    }
    else {
        [param setObject:[NSString stringWithFormat:@"%d", aPage] forKey:@"page"];
    }

    [twitterClient get:type params:param];
}

- (int)restore:(MessageType)aType all:(BOOL)all
{
    // Remove last message which contains load cell
    if (all) {
        [messages removeLastObject];
    }
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement == nil) {
        static char *sql = "SELECT * FROM messages WHERE type = ? order BY id DESC LIMIT ? OFFSET ?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }

    sqlite3_bind_int(select_statement, 1, aType);
    sqlite3_bind_int(select_statement, 2, all ? 200 : 20);
    sqlite3_bind_int(select_statement, 3, (insertPosition) ? [messages count] - 1 : [messages count]);
    int count = 0;
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Message *m = [Message initWithDB:select_statement type:aType];
        [messages addObject:m];
        ++count;
    }
    sqlite3_reset(select_statement);
    
    // Add "Load more 20 messages" cell
    if (!all && [messages count]) {
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
    
    if (insertPosition) {
        [messages removeObjectAtIndex:insertPosition];
    }
    
    BOOL noMoreRead = FALSE;
    int unread = 0;
    LOG(@"Received %d messages", [ary count]);
    
    if ([ary count]) {
        INIT_STOPWATCH;
        sqlite3* database = [DBConnection getSharedDatabase];
        char *errmsg; 
        sqlite3_exec(database, "BEGIN", NULL, NULL, &errmsg); 
        
        // Add messages to the timeline
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
            else if (messageId <= since_id) {
                noMoreRead = TRUE;
            }
        }
        
        sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg); 
        LAP(@"Data inserted");
    }

    if ([ary count] == 20 && !noMoreRead && ++page <= 10) {
        [messages insertObject:[Message messageWithLoadMessage:MSG_TYPE_LOAD_FROM_WEB page:page] atIndex:insertPosition + unread];
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
    
    if (delegate && [delegate respondsToSelector:@selector(timelineDidFailToUpdate)]) {
        [delegate timelineDidFailToUpdate];
	}
    
	[twitterClient autorelease];
	twitterClient = nil;
}

@end
