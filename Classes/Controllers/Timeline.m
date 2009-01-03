#import "Timeline.h"
#import "TimelineCell.h"
#import "JSON.h"
#import "Status.h"
#import "TimeUtils.h"
#import "DBConnection.h"

@implementation Timeline

#define MAX_ROW_COUNT   200

- (id)init
{
	self = [super init];
	statuses = [[NSMutableArray array] retain];
	return self;
}

- (void)dealloc
{
	[statuses release];
	[super dealloc];
}

- (int)countStatuses
{
    return [statuses count];
}

- (Status*)statusAtIndex:(int)i
{
    if (i >= [statuses count]) return NULL;
    return [statuses objectAtIndex:i];
}

-(Status*)statusById:(sqlite_int64)statusId
{
    for (int i = 0; i < [statuses count]; ++i) {
        Status* sts = [statuses objectAtIndex:i];
        if (sts.statusId == statusId) {
            return sts;
        }
    }
    return nil;
}

- (Status*)lastStatus
{
    return [statuses lastObject];
}

- (void)removeStatusAtIndex:(int)index
{
    [statuses removeObjectAtIndex:index];
}

- (void)removeAllStatuses
{
    [statuses removeAllObjects];
}

- (void)removeStatus:(Status*)status
{
    for (int i = 0; i < [statuses count]; ++i) {
        Status* sts = [statuses objectAtIndex:i];
        if (sts.statusId == status.statusId) {
            [statuses removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)removeLastStatus
{
    [statuses removeLastObject];
}

- (void)updateFavorite:(Status*)status
{
    for (int i = 0; i < [statuses count]; ++i) {
        Status* sts = [statuses objectAtIndex:i];
        if (sts.statusId == status.statusId) {
            sts.favorited = status.favorited;
            return;
        }
    }
}

- (void)appendStatus:(Status*)status
{
    [statuses addObject:status];
}

- (void)insertStatus:(Status*)status atIndex:(int)index
{
    [statuses insertObject:status atIndex:index];
}

- (int)indexOfObject:(Status*)status
{
    for (int i = 0; i < [statuses count]; ++i) {
        Status* sts = [statuses objectAtIndex:i];
        if (sts.statusId == status.statusId) {
            return i;
        }
    }
    return -1;
}

- (TimelineCell*)getTimelineCell:(UITableView*)tableView atIndex:(int)index
{
    Status* status = [self statusAtIndex:index];
    if (status == nil) return nil;
    
    TimelineCell* cell = (TimelineCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
    if (!cell) {
        cell = [[[TimelineCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
    }
        
    cell.status = status;
    [cell update];
    return cell;
}

- (int)restore:(TweetType)aType all:(BOOL)all
{
    static Statement *stmt = nil;
    if (stmt == nil) {
        static char *sql = "SELECT * FROM statuses WHERE statuses.type = ? ORDER BY id DESC LIMIT ? OFFSET ?";
        stmt = [DBConnection statementWithQuery:sql];
        [stmt retain];
    }
    
    [stmt bindInt32:aType            forIndex:1];
    [stmt bindInt32:(all) ? 200 : 20 forIndex:2];
    [stmt bindInt32:[statuses count] forIndex:3];

    int count = 0;
    while ([stmt step] == SQLITE_ROW) {
        Status* sts = [Status initWithStatement:stmt type:aType];
        if (sts) {
            [statuses addObject:sts];
            ++count;
        }
    }
    [stmt reset];
    return count;
}

@end
