//
//  UserTimelineController.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserTimelineController.h"
#import "UserMessageCell.h"

@implementation UserTimelineController


- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
	}
	return self;
}


- (void)setMessage:(Message *)message image:(UIImage*)image
{
    userCell.message = message;
    userCell.profileImage.image = image;
    self.title = message.user.screenName;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Message *m = [timeline messageAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        return 112;
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
        return 48;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
    
    if (indexPath.row == 0) {
        return userCell;
    }
    else if (indexPath.row == 1 || indexPath.row == 2) {
		UserMessageCell *cell = [[[UserMessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
        cell.message = userCell.message;
        [cell setType:indexPath.row - 1];
        return cell;
    }
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	// Configure the cell
	return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
*/
/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
	}
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/
/*
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/
/*
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


- (void)dealloc {
	[super dealloc];
}


- (void)viewDidLoad {
	[super viewDidLoad];
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


@end

