#import "TimelineViewController.h"
#import "TwitterPhoxAppDelegate.h"
#import "MessageCell.h"

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
    self.tableView.separatorColor = [UIColor colorWithRed:0.784 green:969 blue:996 alpha:1.0];
	[friendTimeline update:@"statuses/friends_timeline"];
	//[friendTimeline update:@"statuses/replies"];
	//[friendTimeline update:@"direct_messages"];
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
    cell.image = [imageStore getImage:m.user.profileImageUrl];
	[cell update];
	return cell;
}

- (void)dealloc {
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url {
	[self.tableView reloadData];
}

- (void)timelineDidReceiveNewMessage:(Timeline*)sender message:(Message*)msg {
	[imageStore getImage:msg.user.profileImageUrl];
}

- (void)timelineDidUpdate:(Timeline*)sender {
	[self.tableView reloadData];
}



@end
