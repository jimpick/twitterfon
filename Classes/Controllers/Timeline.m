#import "Timeline.h"
#import "TimelineCell.h"
#import "JSON.h"
#import "Status.h"
#import "TimeUtils.h"
#import "DBConnection.h"

static sqlite3_stmt *select_statement = nil;

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
    if (select_statement == nil) {
        static char *sql = "SELECT * FROM statuses,users WHERE statuses.user_id = users.user_id AND statuses.type = ? ORDER BY id DESC LIMIT ? OFFSET ?";
        select_statement = [DBConnection prepate:sql];
    }

    sqlite3_bind_int(select_statement, 1, aType);
    sqlite3_bind_int(select_statement, 2, all ? 200 : 20);
    sqlite3_bind_int(select_statement, 3, [statuses count]);
    int count = 0;
    while (sqlite3_step(select_statement) == SQLITE_ROW) {
        Status* sts = [Status initWithDB:select_statement type:aType];
        [statuses addObject:sts];
        ++count;
    }
    sqlite3_reset(select_statement);
    return count;
}

@end
