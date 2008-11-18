//
//  UserDetailViewController.m
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UserDetailViewController.h"
#import "TwitterFonAppDelegate.h"
#import "WebViewController.h"

@implementation UserDetailViewController

@synthesize user;
@synthesize userView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    return self;
}

- (void)setUser:(User*)aUser
{
    user = aUser;
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([username caseInsensitiveCompare:user.screenName] == NSOrderedSame) {
        ownInfo = true;
    }
    
    userView = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
    userView.hasDetail = true;
    [userView setUser:user delegate:self];
    
    detailView = [[UserDetailView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    
    followStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    followStatus.backgroundColor = [UIColor clearColor];
    followStatus.textColor       = [UIColor darkGrayColor];
    followStatus.shadowColor     = [UIColor whiteColor];
    followStatus.font            = [UIFont boldSystemFontOfSize:16];
    followStatus.lineBreakMode   = UILineBreakModeTailTruncation;
    followStatus.shadowOffset    = CGSizeMake(0, 1);
    
    
    following = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userDidReceive:messages:)];
    [twitterClient getUser:user.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [userView setNeedsDisplay];
    self.title = user.screenName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
        twitterClient = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)dealloc 
{
    [twitterClient release];
    [detailView release];
    [userView release];
    [followStatus release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int ret = 1;
    if (following >= 0) {
        ret = 2;
    }
    
    return ret;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (detailLoaded) ? 1 : 0;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"detailCell"] autorelease];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:detailView];
        }
        else {
            cell.text = [NSString stringWithFormat:@" Device Update %@", isDeviceUpdate ? @"On" : @"Off"];
            if (isDeviceUpdate) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    else if (indexPath.section == 1) {
        cell.textAlignment = UITextAlignmentCenter;
        cell.textColor = [UIColor colorWithRed:0.195 green:0.309 blue:0.520 alpha:1.0];
        if (following) {
            cell.text = @"Remove This User";
        }
        else {
            cell.text = @"Follow This User";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0 && indexPath.section == 1) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(followDidRequest:messages:)];
        [twitterClient friendship:user.screenName create:!following];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return userView;
    }
    else {
        return followStatus;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return userView.height;
    }
    else {
        return 32;
    }
}

- (void)userDidReceive:(TwitterClient*)sender messages:(NSObject*)obj
{
    NSDictionary *dic = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;
        
        detailView.following = [[dic objectForKey:@"friends_count"] longValue];
        detailView.followers = [[dic objectForKey:@"followers_count"] longValue];
        detailView.updates   = [[dic objectForKey:@"statuses_count"] longValue];
        
        isDeviceUpdate = [[dic objectForKey:@"notifications"] boolValue];
        
        detailLoaded = true;

        NSArray *indexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    
    [sender autorelease];
    twitterClient = nil;

    if (!ownInfo) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(friendshipDidCheck:messages:)];
        [twitterClient existFriendship:user.screenName];
    }
}

- (void)friendshipDidCheck:(TwitterClient*)sender messages:(NSObject*)obj
{
    NSNumber *flag = (NSNumber*)obj;
    following = [flag boolValue] ? 1 : 0;
    
    NSString *fmt;
    if (following) {
        fmt = @"    You are following ";
    }
    else {
        fmt = @"    You are not following ";
    }
    followStatus.text = [fmt stringByAppendingString:user.screenName];
    
    
    [self.tableView beginUpdates];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    
    [followStatus setNeedsDisplay];
    
    [sender autorelease];
    twitterClient = nil;
}

- (void)updateFriendship:(BOOL)created
{
    following = created;
    
    NSString *fmt;
    if (following) {
        fmt = @"    You are following ";
    }
    else {
        fmt = @"    You are not following ";
    }
    followStatus.text = [fmt stringByAppendingString:user.screenName];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.tableView.layer addAnimation:animation forKey:@"friendshipButton"];

    [self.tableView reloadData];
}

- (void)followDidRequest:(TwitterClient*)sender messages:(NSObject*)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        BOOL created = (sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP) ? true : false;
        [self updateFriendship:created];
    }
    [sender autorelease];
    twitterClient = nil;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    if ((sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP ||
         sender.request == TWITTER_REQUEST_DESTROY_FRIENDSHIP) &&
        sender.statusCode == 403) {
        BOOL created = (sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP) ? true : false;
        [self updateFriendship:created];
    }
    else {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:error
                                           message:detail
                                          delegate:self
                                 cancelButtonTitle:@"Close"
                                 otherButtonTitles: nil];
        
        [alert show];	
        [alert release];
    }
   
    [sender autorelease];
    twitterClient = nil;
}

- (void)didTouchURL:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openWebView:user.url on:[self navigationController]];
}

@end
