//
//  TwitterFonAppDelegate.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "TimelineViewController.h"
#import "SettingsViewController.h"
#import "UserTimelineController.h"
#import "LinkViewController.h"
#import "DBConnection.h"
#import "TwitterClient.h"
#import "ColorUtils.h"
#import "REString.h"


@interface NSObject (TimelineViewControllerDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)dic;
- (void)postViewAnimationDidFinish;
- (void)didLeaveTab:(UINavigationController*)navigationController;
- (void)didSelectTab:(UINavigationController*)navigationController;
- (void)imageStoreDidGetNewImage:(UIImage*)image;
- (void)updateFavorite:(Message*)message;
- (void)toggleFavorite:(BOOL)favorited message:(Message*)message;
- (void)removeMessage:(Message*)message;
@end

@implementation TwitterFonAppDelegate

@synthesize window;
@synthesize postView;
@synthesize imageStore;
@synthesize selectedTab;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    [DBConnection createEditableCopyOfDatabaseIfNeeded];

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *prevUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"prevUsername"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    
  	BOOL needDeleteMessageCache = [[NSUserDefaults standardUserDefaults] boolForKey:@"deleteMessageCache"];
    
    if ([username caseInsensitiveCompare:prevUsername] != NSOrderedSame) {
        needDeleteMessageCache = true;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"prevUsername"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"deleteMessageCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (needDeleteMessageCache) {
        [DBConnection deleteMessageCache];
    }
    
    [UIColor initTwitterFonColorScheme];
    imageStore = [[ImageStore alloc] initWithDelegate:self];    
    postView = nil;

    selectedTab = 0;
    tabBarController.selectedIndex = TAB_FRIENDS;
    
    // Load views
    NSArray *views = tabBarController.viewControllers;
    
  	BOOL loadall = [[NSUserDefaults standardUserDefaults] boolForKey:@"loadAllTabAtStartup"];
    
    for (int tab = 0; tab < 3; ++tab) {
        UINavigationController* nav = (UINavigationController*)[views objectAtIndex:tab];
        BOOL flag = (loadall) ? true : ((tab == 0) ? true : false);
        [(TimelineViewController*)[nav topViewController] restoreAndLoadTimeline:flag];
    }
    
	[window addSubview:tabBarController.view];
    
    if (username == nil || password == nil ||
        [username length] == 0 || [password length] == 0) {
        [self openSettingsView];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // Always return yes so far
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (postView != nil) {
        [self.postView saveTweet];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (postView != nil) {
        [self.postView checkProgressWindowState];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if (postView != nil) {
        [self.postView saveTweet];
        [postView release];
    }
    [DBConnection closeDatabase];
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
    [imageStore release];
	[super dealloc];
}

- (void)openWebView:(NSString*)url on:(UINavigationController*)nav
{
    if (webView == nil) {
        webView = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    }
    webView.hidesBottomBarWhenPushed = YES;
    [webView setUrl:url];
    [nav pushViewController:webView animated:YES];
}

- (void)openWebView:(NSString*)url
{
    if (webView == nil) {
        webView = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    }
    webView.hidesBottomBarWhenPushed = YES;
    [webView setUrl:url];
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    [nav pushViewController:webView animated:YES];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [imageStore didReceiveMemoryWarning];
}

- (void)openSettingsView
{
    SettingsViewController *settings = [[[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil] autorelease];
    UINavigationController *parentNav = [[[UINavigationController alloc] initWithRootViewController:settings] autorelease];
        
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
    [nav presentModalViewController:parentNav animated:YES];
}

- (void)closeSettingsView
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];    
    [(TimelineViewController*)[nav topViewController] reload:self];
}

- (PostViewController*)postView
{
    if (postView == nil) {
        postView = [[PostViewController alloc] initWithNibName:@"PostView" bundle:nil];
    }
    postView.navigation = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    return postView;
}

- (IBAction) post: (id) sender
{
    if (tabBarController.selectedIndex == TAB_MESSAGES) {
        [self.postView editDirectMessage:nil];
    }
    else {
        [self.postView reply:nil];
    }
}

- (void)profileImageDidGetNewImage:(UIImage*)image delegate:(id)delegate
{
    for (UINavigationController *c in tabBarController.viewControllers) {
        if (c.topViewController == delegate && [delegate respondsToSelector:@selector(imageStoreDidGetNewImage:)]) {
        [delegate imageStoreDidGetNewImage:image];
        }
    }
}

//
// UITabBarControllerDelegate
//
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    UIViewController *c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didLeaveTab:)]) {
        [c didLeaveTab:nav];
    }
    selectedTab = tabBar.selectedIndex;

    nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(didSelectTab:)]) {
        [c didSelectTab:nav];
    }
}

//
// Handling links
//
static NSString *urlRegexp  = @"(((http(s?))\\:\\/\\/)([0-9a-zA-Z\\-]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/([0-9a-zA-Z_#!:.?+=&%@~*\';,\\-\\/\\$])*)?)";
static NSString *nameRegexp = @"(@[0-9a-zA-Z_]+)";

- (void)didTouchLinkButton:(Message*)message
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    
    NSMutableArray *links = [NSMutableArray array];
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *tmp = message.text;
    
    while ([tmp matches:urlRegexp withSubstring:array]) {
        NSString *url = [array objectAtIndex:0];
        [links addObject:url];
        NSRange r = [tmp rangeOfString:url];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }
    
    tmp = message.text;
    while ([tmp matches:nameRegexp withSubstring:array]) {
        NSString *username = [array objectAtIndex:0];
        [links addObject:username];
        NSRange r = [tmp rangeOfString:username];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }
    
    if (message.inReplyToMessageId) {
        Message *m = [Message messageWithId:message.inReplyToMessageId];
        if (m) {
            [links addObject:[NSString stringWithFormat:@"%@:%@", m.user.screenName, m.text]];
        }
    }
    
    if ([links count] == 1) {
        NSString* url = [links objectAtIndex:0];
        NSRange r = [url rangeOfString:@"http://"];
        if (r.location != NSNotFound) {
            [self openWebView:url on:nav];
        }
        else {
            UserTimelineController *userTimeline = [[[UserTimelineController alloc] initWithNibName:nil bundle:nil] autorelease];
            NSString *screenName = [links objectAtIndex:0];
            [userTimeline loadUserTimeline:[screenName substringFromIndex:1]];
            [nav pushViewController:userTimeline animated:true];
        }
    }
    else {
        nav.navigationBar.tintColor = nil;
        
        LinkViewController* linkView = [[[LinkViewController alloc] init] autorelease];
        linkView.message = message;
        linkView.links   = links;
        [nav pushViewController:linkView animated:true];
    }
}

//
// Bypass posted message to friends timeline view...
//
- (void)postTweetDidSucceed:(NSDictionary*)dic isDirectMessage:(BOOL)isDirectMessage
{
    UINavigationController* nav;
    if (isDirectMessage) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_MESSAGES];
    }
    else {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];
    }
    UIViewController *c = [nav.viewControllers objectAtIndex:0];;
    [c postTweetDidSucceed:dic];
}

- (void)postViewAnimationDidFinish:(BOOL)isDirectMessage
{
    UINavigationController *nav = nil;
    if (isDirectMessage == false && selectedTab == TAB_FRIENDS) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];    
    }        
    else if (isDirectMessage && selectedTab == TAB_MESSAGES) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_MESSAGES];    
    }
    UIViewController *c = [nav.viewControllers objectAtIndex:0];
    if ([c respondsToSelector:@selector(postViewAnimationDidFinish)]) {
        [c postViewAnimationDidFinish];
    }
}

//
// Bypass message deletion and toggle favorite completed
//
- (void)messageDidDelete:(TwitterClient*)client messages:(NSObject*)obj
{
    Message *m = (Message*)client.context;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 messageId = [[dic objectForKey:@"id"] longLongValue];        
        if (m.messageId == messageId) {
            [m deleteFromDB];
        }
    }
    [m release];
}

//
// Handle favorites
//
- (void)toggleFavorite:(Message*)message
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(favoriteDidChange:messages:)];
    client.context = [message retain];
    [client favorite:message];
}

- (void)favoriteDidChange:(TwitterClient*)sender messages:(NSObject*)obj
{
    Message *m = sender.context;
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 messageId = [[dic objectForKey:@"id"] longLongValue];
        if (m.messageId != messageId) {
            NSLog(@"Someting wrong with contet. Ignore error...");
            return;
        }
        BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
        m.favorited = favorited;
        [m updateFavoriteState];
        
        UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
        UIViewController *c = nav.topViewController;
        if ([c respondsToSelector:@selector(toggleFavorite:message:)]) {
            [c toggleFavorite:favorited message:m];
        }
        
        c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(updateFavorite:)]) {
            [c updateFavorite:m];
        }
    }
    [m release];
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    Message *m = sender.context;
    
    if (sender.request == TWITTER_REQUEST_FAVORITE ||
        sender.request == TWITTER_REQUEST_DESTROY_FAVORITE) {
        if (sender.statusCode == 404 || sender.statusCode == 403) {
            BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
            m.favorited = favorited;
            [m updateFavoriteState];
            UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
            UIViewController *c = nav.topViewController;
            if ([c respondsToSelector:@selector(toggleFavorite:message:)]) {
                [c toggleFavorite:favorited message:m];
            }
        }
    }
    else {
        if (sender.statusCode == 404) {
            [m deleteFromDB];
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
    }

    [m release];
}

@end

