//
//  TableViewController.m
//  TwitterPhox
//
//  Created by kaz on 7/14/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TableViewController.h"
#import "MessageCell.h"

@implementation TableViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
//	self.tableView.separatorColor = [UIColor colorWithRed:0.784 green:969 blue:996 alpha:1.0];
	[friendTimeline update];
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
	cell.imageView.image = [imageStore getImage:m.user.profileImageUrl];
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
    //[self.tableView setNeedsDisplay];
}
 
- (IBAction)refresh:(id)sender {
	[friendTimeline update];
}
 
- (void)friendTimelineControllerDidReceiveNewMessage:(FriendTimelineController*)sender message:(Message*)msg {
	[imageStore getImage:msg.user.profileImageUrl];
}
 
- (void)friendTimelineControllerDidUpdate:(FriendTimelineController*)sender {
	[self.tableView reloadData];
}


@end

