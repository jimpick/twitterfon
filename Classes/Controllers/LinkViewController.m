//
//  LinkViewController.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "LinkViewController.h"
#import "TwitterFonAppDelegate.h"
#import "UserTimelineController.h"

@implementation LinkViewController

@synthesize links;
@synthesize message;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Links";
}

- (void)dealloc
{
    [message release];
    [links release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [links count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"LinkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.text = [links objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSRange r = [cell.text rangeOfString:@"http://"];
    if (r.location != NSNotFound) {
        [appDelegate openWebView:cell.text];
    }
    else {
        r = [cell.text rangeOfString:@"#"];
        if (r.location == 0) {
            [appDelegate search:cell.text];
        }
        else {
            UserTimelineController* userTimeline = [[[UserTimelineController alloc] initWithNibName:nil bundle:nil] autorelease];
            [userTimeline loadUserTimeline:[cell.text substringFromIndex:1]];
            [self.navigationController pushViewController:userTimeline animated:true];
        }
    }
}

@end

