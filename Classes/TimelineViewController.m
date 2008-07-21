#import <QuartzCore/QuartzCore.h>
#import "TimelineViewController.h"
#import "TwitterFonAppDelegate.h"
#import "MessageCell.h"
#import "ColorUtils.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username;
@end 

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    loaded = false;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if (self = [super initWithStyle:style]) {
	}
	return self;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [timeline countMessages];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString* MyIdentifier = @"MessageCell";
	
	MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	Message* m = [timeline messageAtIndex:indexPath.row];
	if (!cell) {
		cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	cell.message = m;
    cell.image = [imageStore getImage:m.user delegate:self];

    if (index == 1) {
        NSString *str = [NSString stringWithFormat:@"@%@", username];
        NSRange r = [m.text rangeOfString:str];
        if (r.location != NSNotFound) {
            cell.contentView.backgroundColor = [UIColor repliesColor:m.unread];
        }
        else {
            cell.contentView.backgroundColor = [UIColor friendColor:m.unread];
        }
    }
    else if (index == 2) {
        cell.contentView.backgroundColor = [UIColor repliesColor:m.unread];
    }
    else if (index == 3) {
        cell.contentView.backgroundColor = [UIColor messageColor:m.unread];
    }
    
	[cell update];
    
	return cell;
}

- (void)dealloc {
	[super dealloc];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect bounds;
    CGRect result;
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectZero];
    Message *m = [timeline messageAtIndex:indexPath.row];
    
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.numberOfLines = 10;
    
    textLabel.text = m.text;
    bounds = CGRectMake(0, 0, 240, 200);
    result = [textLabel textRectForBounds:bounds limitedToNumberOfLines:10];
    result.size.height += 18;
    if (result.size.height < 48 + 1) result.size.height = 48 + 1;
    [textLabel release];
    return result.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* views = [tab viewControllers];
    PostViewController *postView = (PostViewController*)[views objectAtIndex:0];
  	Message* m = [timeline messageAtIndex:indexPath.row];
    tab.selectedIndex = 0;
    if (index != 3) {
        postView.text.text  = [NSString stringWithFormat:@"%@@%@ ", postView.text.text, m.user.screenName];
    }
    else {
        postView.text.text  = [NSString stringWithFormat:@"d %@ %@ ", m.user.screenName, postView.text.text];
    }
    [postView setCharCount];
}

- (void)postTweetDidSucceed:(Message*)message
{
   
    NSArray *indexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil];
    [timeline insertMessage:message];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];    
}

//
// UITabBarControllerDelegate
//
- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)aUsername
{
    username = aUsername;
    index = tabBar.selectedIndex;
    tab = tabBar;

    if (!loaded) {
        [timeline restore:index - 1];
    }

    switch (index) {
        case 1:
            self.tableView.separatorColor = [UIColor friendColorBorder];
            if (!loaded) [timeline update:MSG_TYPE_FRIENDS];
            break;
            
        case 2:
            self.tableView.separatorColor =  [UIColor repliesColorBorder];
            self.tableView.backgroundColor = [UIColor repliesColor];
            if (!loaded) [timeline update:MSG_TYPE_REPLIES];
            break;
            
        case 3:
            self.tableView.separatorColor =  [UIColor messageColorBorder];
            self.tableView.backgroundColor = [UIColor messageColor];
            if (!loaded) [timeline update:MSG_TYPE_MESSAGES];
    }
    loaded = true;
}

//
// ImageStoreDelegate
//
- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

//
// TimelineDownloaderDelegate
//
- (void)timelineDidReceiveNewMessage:(Timeline*)sender message:(Message*)msg
{
	[imageStore getImage:msg.user delegate:self];
}

- (void)timelineDidUpdate:(Timeline*)sender indexPaths:(NSArray*)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];    
}
@end
