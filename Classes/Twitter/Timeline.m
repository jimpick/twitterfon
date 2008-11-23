#import "Timeline.h"
#import "JSON.h"
#import "Message.h"
#import "TimeUtils.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

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
	[messages release];
	[super dealloc];
}

- (int)countMessages
{
    return [messages count];
}

- (Message*)messageAtIndex:(int)i
{
    if (i >= [messages count]) return NULL;
    return [messages objectAtIndex:i];
}

-(Message*)messageById:(sqlite_int64)messageId
{
    for (int i = 0; i < [messages count]; ++i) {
        Message *m = [messages objectAtIndex:i];
        if (m.messageId == messageId) {
            return m;
        }
    }
    return nil;
}

- (Message*)lastMessage
{
    return [messages lastObject];
}

- (void)removeMessageAtIndex:(int)index
{
    [messages removeObjectAtIndex:index];
}

- (void)removeAllMessages
{
    [messages removeAllObjects];
}

- (void)removeMessage:(Message*)message
{
    for (int i = 0; i < [messages count]; ++i) {
        Message *m = [messages objectAtIndex:i];
        if (m.messageId == message.messageId) {
            [messages removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)removeLastMessage
{
    [messages removeLastObject];
}

- (void)updateFavorite:(Message*)message
{
    for (int i = 0; i < [messages count]; ++i) {
        Message *m = [messages objectAtIndex:i];
        if (m.messageId == message.messageId) {
            m.favorited = message.favorited;
            return;
        }
    }
}

- (void)appendMessage:(Message*)m
{
    [messages addObject:m];
}

- (void)insertMessage:(Message*)m atIndex:(int)index
{
    [messages insertObject:m atIndex:index];
}

- (int)indexOfObject:(Message*)message
{
    for (int i = 0; i < [messages count]; ++i) {
        Message *m = [messages objectAtIndex:i];
        if (m.messageId == message.messageId) {
            return i;
        }
    }
    return -1;
}

- (int)restore:(MessageType)aType all:(BOOL)all
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement == nil) {
        static char *sql = "SELECT * FROM messages WHERE messages.type = ? ORDER BY id DESC LIMIT ? OFFSET ?";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }

    sqlite3_bind_int(select_statement, 1, aType);
    sqlite3_bind_int(select_statement, 2, all ? 200 : 20);
    sqlite3_bind_int(select_statement, 3, [messages count]);
    int count = 0;
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Message *m = [Message initWithDB:select_statement type:aType];
        [messages addObject:m];
        ++count;
    }
    sqlite3_reset(select_statement);
    return count;
}

@end
