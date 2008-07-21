#import "Timeline.h"
#import "JSON.h"
#import "Message.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

@interface NSObject (TimelineDelegate)
- (void)timelineDidReceiveNewMessage:(Timeline*)sender message:(Message*)msg;
- (void)timelineDidUpdate:(Timeline*)sender;
@end

@implementation Timeline

@synthesize messages;


- (id)init
{
	self = [super init];
	messages = [[NSMutableArray array] retain];
	return self;
}

- (void)dealloc
{
	[messages release];
	[timelineConn release];
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

- (void)update:(MessageType)type
{
	if (timelineConn) return;
	
	timelineConn = [[TimelineDownloader alloc] initWithDelegate:self];
	[timelineConn get:type];
}

- (void)restore:(MessageType)type
{
    sqlite3* database = [DBConnection getSharedDatabase];

    if (select_statement== nil) {
        static char *sql = "SELECT * FROM timelines WHERE type = ? order BY id limit 40";
        if (sqlite3_prepare_v2(database, sql, -1, &select_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }    

    sqlite3_bind_int(select_statement, 1, type);
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Message *m = [[Message alloc] init];
        m.user     = [[User alloc] init];
        m.messageId   = (int)sqlite3_column_text(select_statement, 0);
        m.user.userId = (int)sqlite3_column_text(select_statement, 2);
        m.user.screenName      = [[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 3)] copy];
        m.user.profileImageUrl = [[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 4)] copy];
        m.text                 = [[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_statement, 5)] copy];
        
        [messages addObject:m];
    }
    sqlite3_reset(select_statement);
  
}

- (void)timelineDownloaderDidSucceed:(TimelineDownloader*)sender messages:(NSArray*)ary
{
	[timelineConn autorelease];
	timelineConn = nil;

	long lastMessageId = 0;
	if ([messages count] > 0) lastMessageId = ((Message*)[messages objectAtIndex:0]).messageId;
	
	if (delegate) {
		int i;
		for (i=0; i < [ary count]; ++i) {
			Message* m = [ary objectAtIndex:i];
			if (m.messageId > lastMessageId) {
				[messages addObject:m];
				
				if ([delegate respondsToSelector:@selector(timelineDidReceiveNewMessage:message:)]) {
					[delegate timelineDidReceiveNewMessage:self message:m];
				}
			}
		}
		
		if ([delegate respondsToSelector:@selector(timelineDidUpdate:)]) {
			[delegate timelineDidUpdate:self];
		}
	}
}

- (void)timelineDownloaderDidFail:(TimelineDownloader*)sender error:(NSError*)error
{
	[timelineConn autorelease];
	timelineConn = nil;
}

@end
