//
//  UserDetailViewController.m
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "TwitterFonAppDelegate.h"
#import "WebViewController.h"
#import "FriendsViewController.h"
#import "UserTimelineController.h"
#import "Followee.h"
#import "ColorUtils.h"

#define USE_FRIENDSHIP_EXISTS_METHOD

enum {
    ROW_FRIENDS,
    ROW_FOLLOWERS,
    ROW_UPDATES,
    ROW_FAVORITES,
    NUM_ROWS,
};

@implementation ProfileViewController

- (id)initWithProfile:(User*)aUser
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    user = [aUser copy];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if ([username caseInsensitiveCompare:user.screenName] == NSOrderedSame) {
        ownInfo = true;
    }
    else {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(postTweet:)]; 
        self.navigationItem.rightBarButtonItem = button;
    }
    
    
    userView = [[UserView alloc] initWithFrame:CGRectMake(0, 0, 320, 387)];
    userView.hasDetail = true;
    user.imageContainer = userView;
    [userView setUser:user];

    return self;
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
    if (!detailLoaded) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(userDidReceive:obj:)];
        [twitterClient getUser:user.screenName];
    }
}

- (void)viewDidDisappear:(BOOL)animated 
{
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
    user.imageContainer = nil;
    [user release];
    [twitterClient release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (followingLoaded) ? 2 : 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return (detailLoaded) ? NUM_ROWS : 0;
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.row) {
            case ROW_FRIENDS:
                cell.text = [NSString stringWithFormat:@" %d following", user.friendsCount];
                break;
            case ROW_FOLLOWERS:
                cell.text = [NSString stringWithFormat:@" %d follower%s", user.followersCount, (user.followersCount) ? "s" : ""];
                break;
            case ROW_UPDATES:
                cell.text = [NSString stringWithFormat:@" %d update%s", user.statusesCount, (user.statusesCount) ? "s" : ""];
                break;
            case ROW_FAVORITES:
                cell.text = [NSString stringWithFormat:@" %d favorite%s", user.favoritesCount, (user.favoritesCount) ? "s" : ""];
                break;
        }
    }
    else if (indexPath.section == 1) {
        cell.textAlignment = UITextAlignmentCenter;
        cell.textColor = [UIColor cellLabelColor];
        if (user.following) {
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
    if (indexPath.section == 0) {
        if (indexPath.row == ROW_FAVORITES) {
        }
        else if (indexPath.row == ROW_UPDATES) {
            if (user.statusesCount != 0) {
                UserTimelineController* userTimeline = [[[UserTimelineController alloc] init] autorelease];
                [userTimeline loadUserTimeline:user.screenName];
                [self.navigationController pushViewController:userTimeline animated:true];
            }
        }
        else {
            int count = (indexPath.row == ROW_FOLLOWERS) ? user.followersCount : user.friendsCount;
            if (count > 0) {
                FriendsViewController *friends = [[[FriendsViewController alloc] initWithScreenName:user.screenName isFollowers:(indexPath.row == 1)] autorelease];
                [self.navigationController pushViewController:friends animated:true];
            }
        }
        
    }
    if (indexPath.row == 0 && indexPath.section == 1) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(followDidRequest:obj:)];
        [twitterClient friendship:user.screenName create:!user.following];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return userView;
    }
    else {
        return nil;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    if (section == 1) {
        NSString *fmt;
        if (user.following) {
            fmt = @"You are following ";
        }
        else {
            fmt = @"You are not following ";
        }
        return [fmt stringByAppendingString:user.screenName];
    }
    else {
        return nil;
    }
}

- (void)userDidReceive:(TwitterClient*)sender obj:(NSObject*)obj
{
    NSDictionary *dic = nil;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;

        [user updateWithJSonDictionary:dic];
        [userView setUser:user];
        detailLoaded = true;
#ifndef USE_FRIENDSHIP_EXISTS_METHOD        
        followingLoaded = true;
#endif

        NSArray *indexPath = [NSArray arrayWithObjects:
                              [NSIndexPath indexPathForRow:0 inSection:0],
                              [NSIndexPath indexPathForRow:1 inSection:0],
                              [NSIndexPath indexPathForRow:2 inSection:0],
                              [NSIndexPath indexPathForRow:3 inSection:0],
                              nil];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
#ifndef USE_FRIENDSHIP_EXISTS_METHOD        
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];  	 	 
#endif
        [self.tableView endUpdates];
    }
    
    twitterClient = nil;
#ifdef USE_FRIENDSHIP_EXISTS_METHOD
    if (!ownInfo) {   	 	 
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(friendshipDidCheck:obj:)];  	 	 
        [twitterClient existFriendship:user.screenName];  	 	 
    }
#endif
}

- (void)friendshipDidCheck:(TwitterClient*)sender obj:(NSObject*)obj   	 	 
{
    followingLoaded = true;
    NSNumber *flag = (NSNumber*)obj;  	 	 
    user.following = [flag boolValue] ? 1 : 0;
    [Followee updateDB:user];

    [self.tableView beginUpdates];  	 	 
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationTop];  	 	 
    [self.tableView endUpdates];  	 	 
    
    twitterClient = nil;
}
    

- (void)updateFriendship:(BOOL)created
{
    user.following = created;
    [Followee updateDB:user];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setDuration:0.25];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.tableView.layer addAnimation:animation forKey:@"friendshipButton"];

    [self.tableView reloadData];
}

- (void)followDidRequest:(TwitterClient*)sender obj:(NSObject*)obj
{
    if ([obj isKindOfClass:[NSDictionary class]]) {
        BOOL created = (sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP) ? true : false;
        [self updateFriendship:created];
    }
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
        [[TwitterFonAppDelegate getAppDelegate] alert:error message:detail];
    }
   
    twitterClient = nil;
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if ([self tabBarController].selectedIndex == TWEET_TYPE_MESSAGES) {
        [postView editDirectMessage:user.screenName];
    }
    else {
        [postView reply:user.screenName];
    }
}

@end
