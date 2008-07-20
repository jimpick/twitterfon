#import <QuartzCore/QuartzCore.h>
#import "TimelineViewController.h"
#import "TwitterPhoxAppDelegate.h"
#import "MessageCell.h"

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
	return [friendTimeline countMessages];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString* MyIdentifier = @"MessageCell";
	
	MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	Message* m = [friendTimeline messageAtIndex:indexPath.row];
	if (!cell) {
		cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	cell.message = m;
    cell.image = [imageStore getImage:m.user delegate:self];
	[cell update];
    if (index == 1) {
        NSString *str = [NSString stringWithFormat:@"@%@", username];
        NSRange r = [m.text rangeOfString:str];
        if (r.location != NSNotFound) {

            cell.contentView.backgroundColor = [UIColor colorWithRed:0.745 green:0.910 blue:0.608 alpha:1.0];
        }
        else {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.682 green:0.914 blue:0.925 alpha:1.0];
        }
    }
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
    Message *m = [friendTimeline messageAtIndex:indexPath.row];
    
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
  	Message* m = [friendTimeline messageAtIndex:indexPath.row];
    tab.selectedIndex = 0;
    if (index != 3) {
        postView.text.text  = [NSString stringWithFormat:@"%@@%@ ", postView.text.text, m.user.screenName];
    }
    else {
        postView.text.text  = [NSString stringWithFormat:@"d %@ %@ ", m.user.screenName, postView.text.text];
    }
    [postView setCharCount];
}

//
// UITabBarControllerDelegate
//
- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)aUsername
{
    username = aUsername;
    index = tabBar.selectedIndex;
    tab = tabBar;
    if (index == 1) {
        self.tableView.separatorColor = [UIColor colorWithRed:0.784 green:0.969 blue:0.996 alpha:1.0];
        if (!loaded) [friendTimeline update:@"statuses/friends_timeline"];
    }
    else if (index == 2) {
        self.tableView.separatorColor =  [UIColor colorWithRed:0.894 green:1.000 blue:0.800 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.745 green:0.910 blue:0.608 alpha:1.0];
        if (!loaded) [friendTimeline update:@"statuses/replies"];
    }
    else if (index == 3) {
        self.tableView.separatorColor =  [UIColor colorWithRed:0.992 green:0.910 blue:0.800 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.878 green:0.729 blue:0.545 alpha:1.0];
        if (!loaded) [friendTimeline update:@"direct_messages"];
    }
    loaded = true;
}

//
// ImageStoreDelegate
//
- (void)imageStoreDidGetNewImage:(UIImage*)image {
	[self.tableView reloadData];
}

//
// TimelineDownloaderDelegate
//
- (void)timelineDidReceiveNewMessage:(Timeline*)sender message:(Message*)msg {
	[imageStore getImage:msg.user delegate:self];
}

- (void)timelineDidUpdate:(Timeline*)sender {
	[self.tableView reloadData];
}



@end
