#import "Tweet.h"
#import "REString.h"

@implementation Tweet

@synthesize text;
@synthesize createdAt;
@synthesize timestamp;

@synthesize unread;
@synthesize hasReply;
@synthesize type;
@synthesize cellType;

@synthesize accessoryType;

- (void)dealloc
{
    [text release];
    [timestamp release];
  	[super dealloc];
}

- (id)copyWithZone:(NSZone*)zone
{
    Tweet* dist = [[[self class] allocWithZone:zone] init];
	dist.text       = text;
    dist.createdAt  = createdAt;
    dist.timestamp  = timestamp;

    dist.unread     = unread;
    dist.hasReply   = hasReply;
    dist.type       = type;
    dist.cellType   = cellType;
    
    dist.accessoryType = accessoryType;
    
    return dist;
}

static NSString *userRegexp = @"@([0-9a-zA-Z_]+)";
static NSString *hashRegexp = @"(#[a-zA-Z0-9\\-_\\.+:=]+)";

- (void)updateAttribute
{
    NSRange range;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int hasUsername = 0;
    hasReply = false;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *tmp = text;
    
    while ([tmp matches:userRegexp withSubstring:array]) {
        NSString *match = [array objectAtIndex:0]; 
        if ([username caseInsensitiveCompare:match] == NSOrderedSame) {
            hasReply = true;
            if (type != TWEET_TYPE_REPLIES) {
                ++hasUsername;
            }
        }
        else {
            ++hasUsername;
        }
        range = [tmp rangeOfString:match];
        tmp = [tmp substringFromIndex:range.location + range.length];
        [array removeAllObjects];
    }
    
    tmp = text;
    if ([tmp matches:hashRegexp withSubstring:array]) {
        hasUsername = true;
    }
    
    [array release];
   
    range = [text rangeOfString:@"http://"];
    if (range.location != NSNotFound || hasUsername) {    
        accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        if (cellType == TWEET_CELL_TYPE_DETAIL) {
            accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    // Convert timestamp string to UNIX time
    //
    struct tm created;
    setenv("TZ", "GMT", 1);
    time_t now;
    time(&now);
    
    if (!createdAt) {
        if (stringOfCreatedAt) {
            if (strptime([stringOfCreatedAt UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                strptime([stringOfCreatedAt UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
            }
            createdAt = mktime(&created);
        }
    }
}

- (NSString*)timestamp
{
    // Calculate distance time string
    //
    setenv("TZ", "GMT", 1);
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "second ago" : "seconds ago"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "minute ago" : "minutes ago"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "hour ago" : "hours ago"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "day ago" : "days ago"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        self.timestamp = [NSString stringWithFormat:@"%d %s", distance, (distance == 1) ? "week ago" : "weeks ago"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        self.timestamp = [dateFormatter stringFromDate:date];
    }
    return timestamp;
}

@end
