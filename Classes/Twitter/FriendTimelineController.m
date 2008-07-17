#import "FriendTimelineController.h"
#import "JSON.h"

@interface NSObject (FriendTimelineControllerDelegate)
- (void)friendTimelineControllerDidReceiveNewMessage:(FriendTimelineController*)sender message:(Message*)msg;
- (void)friendTimelineControllerDidUpdate:(FriendTimelineController*)sender;
@end


@implementation FriendTimelineController

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

- (void)update
{
	if (timelineConn) return;
	
	timelineConn = [[FriendTimelineDownloader alloc] initWithDelegate:self];
	[timelineConn get];
}

- (void)friendTimelineDownloaderDidSucceed:(FriendTimelineDownloader*)sender messages:(NSArray*)ary
{
	NSLog(@"timeline ok");
	
	[timelineConn autorelease];
	timelineConn = nil;

	long lastMessageId = 0;
	if ([messages count] > 0) lastMessageId = ((Message*)[messages objectAtIndex:0]).messageId;
	
	if (delegate) {
		int i;
		//for (i=[ary count]-1; i>=0; i--) {
		for (i=0; i < [ary count]; ++i) {
			Message* m = [ary objectAtIndex:i];
			if (m.messageId > lastMessageId) {
				[messages addObject:m];
				
				if ([delegate respondsToSelector:@selector(friendTimelineControllerDidReceiveNewMessage:message:)]) {
					[delegate friendTimelineControllerDidReceiveNewMessage:self message:m];
				}
			}
		}
		
		if ([delegate respondsToSelector:@selector(friendTimelineControllerDidUpdate:)]) {
			[delegate friendTimelineControllerDidUpdate:self];
		}
	}
}

- (void)friendTimelineDownloaderDidFail:(FriendTimelineDownloader*)sender error:(NSError*)error
{
	NSLog(@"timeline error");
	
	[timelineConn autorelease];
	timelineConn = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect bounds;
    CGRect result;
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    Message *m = [self messageAtIndex: indexPath.row];

    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.numberOfLines = 10;
    
    textLabel.text = m.text;
    bounds = CGRectMake(0, 0, 240, 200);
    result = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
    result.size.height += 18 + 2;
    if (result.size.height < 48 + 1) result.size.height = 48 + 1;
    [textLabel release];
    return result.size.height;
}

@end
