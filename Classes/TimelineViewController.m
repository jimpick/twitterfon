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

//
// UITabBarControllerDelegate
//
- (void)didSelectViewController:(int)aIndex
{
    index = aIndex;
    NSLog(@"Select view %d", index);
    switch (index) {
    case 1:
        self.tableView.separatorColor = [UIColor colorWithRed:0.784 green:0.969 blue:0.996 alpha:1.0];
        [friendTimeline update:@"statuses/friends_timeline"];
        break;
        
    case 2:
        self.tableView.separatorColor =  [UIColor colorWithRed:0.894 green:1.000 blue:0.800 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.745 green:0.910 blue:0.608 alpha:1.0];
        [friendTimeline update:@"statuses/replies"];
        break;
        
    case 3:
        self.tableView.separatorColor =  [UIColor colorWithRed:0.992 green:0.910 blue:0.800 alpha:1.0];
        self.tableView.backgroundColor = [UIColor colorWithRed:0.878 green:0.729 blue:0.545 alpha:1.0];
        [friendTimeline update:@"direct_messages"];
        break;
    }
}

//
// ImageStoreDelegate
//
- (void)imageStoreDidGetNewImage:(ImageStore*)sender url:(NSString*)url {
	[self.tableView reloadData];
}

- (void)timelineDidReceiveNewMessage:(Timeline*)sender message:(Message*)msg {
	[imageStore getImage:msg.user.profileImageUrl];
}

//
// TimelineDelegate
//
- (void)timelineDidUpdate:(Timeline*)sender {
	[self.tableView reloadData];
}



@end
