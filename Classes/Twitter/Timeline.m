#import "Timeline.h"
#import "JSON.h"

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

- (void)update:(NSString*)method
{
	if (timelineConn) return;
	
	timelineConn = [[TimelineDownloader alloc] initWithDelegate:self];
	[timelineConn get:method];
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
