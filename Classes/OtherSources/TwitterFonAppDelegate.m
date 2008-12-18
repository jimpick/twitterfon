//
//  TwitterFonAppDelegate.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "FriendsTimelineController.h"
#import "SearchViewController.h"
#import "UserTimelineController.h"
#import "LinkViewController.h"
#import "DBConnection.h"
#import "TwitterClient.h"
#import "ColorUtils.h"
#import "REString.h"


@interface NSObject (TwitterFonAppDelegateDelegate)
- (void)postViewAnimationDidFinish;
- (void)didLeaveTab:(UINavigationController*)navigationController;
- (void)didSelectTab:(UINavigationController*)navigationController;
- (void)updateFavorite:(Status*)status;
- (void)toggleFavorite:(BOOL)favorited status:(Status*)status;
@end

@interface TwitterFonAppDelegate(Private)
- (void)setNextTimer:(NSTimeInterval)interval;
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
    [DBConnection getSharedDatabase];

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
    imageStore = [[ImageStore alloc] init];
    postView = nil;

    selectedTab = 0;
    tabBarController.selectedIndex = TAB_FRIENDS;
    
    // Load views
    NSArray *views = tabBarController.viewControllers;

    BOOL loadall;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loadAllTabOnLaunch"] == nil) {
        loadall = true;
    }
    else {
        loadall = [[NSUserDefaults standardUserDefaults] boolForKey:@"loadAllTabOnLaunch"];
    }
    
    for (int tab = 0; tab < 3; ++tab) {
        UINavigationController* nav = (UINavigationController*)[views objectAtIndex:tab];
        BOOL flag = (loadall) ? true : ((tab == 0) ? true : false);
        [(FriendsTimelineController*)[nav topViewController] restoreAndLoadTimeline:flag];
    }
    
	[window addSubview:tabBarController.view];
    
    if (username == nil || password == nil ||
        [username length] == 0 || [password length] == 0) {
        [self openSettingsView];
    }
    int interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"autoRefresh"];
    autoRefreshInterval = 0;
    if (interval > 0) {
        autoRefreshInterval = interval * 60;
        if (autoRefreshInterval < 180) autoRefreshInterval = 180;
        [self setNextTimer:autoRefreshInterval];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    NSString *method = [[url path] substringFromIndex:1];
#if 0    
    [self alert:method message:[url query]]
#endif    
    if ([method isEqualToString:@"post"]) {
        NSMutableArray *array = [NSMutableArray array];
        if ([[url query] matches:@".*twitter.com/([A-Za-z0-9_]+)" withSubstring:array]) {
            UserTimelineController *userTimeline = [[[UserTimelineController alloc] init] autorelease];
            [userTimeline loadUserTimeline:[array objectAtIndex:0]];
            [nav pushViewController:userTimeline animated:false];
        }
        else {
            [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(postURL:) userInfo:url repeats:false];
        }
    }
    if ([method isEqualToString:@"user_timeline"]) {
        UserTimelineController *userTimeline = [[[UserTimelineController alloc] init] autorelease];
        [userTimeline loadUserTimeline:[url query]];
        [nav pushViewController:userTimeline animated:false];
    }
    if ([method isEqualToString:@"search"]) {
        [self search:[url query]];
    }
    return YES;
}

- (void)postURL:(NSTimer*)timer
{
    NSURL *url = [timer userInfo];
    [self.postView editWithURL:[url query]];
}

- (void)setNextTimer:(NSTimeInterval)interval
{
    autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(autoRefresh:) userInfo:nil repeats:false];    
}

- (void)autoRefresh:(NSTimer*)timer
{
    [lastRefreshDate release];
    lastRefreshDate = [[NSDate date] retain];
    NSArray *views = tabBarController.viewControllers;
    for (int i = 0; i < [views count]; ++i) {
        UINavigationController* nav = (UINavigationController*)[views objectAtIndex:i];
        UIViewController *c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(autoRefresh)]) {
            [c performSelector:@selector(autoRefresh)];
        }
    }

    [self setNextTimer:autoRefreshInterval];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    if (autoRefreshTimer) {
        [autoRefreshTimer invalidate];
        autoRefreshTimer = nil;
    }
    
    if (postView != nil) {
        [self.postView saveTweet];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (lastRefreshDate == nil) {
        lastRefreshDate = [[NSDate date] retain];
    }
    else if (autoRefreshInterval) {
        NSDate *now = [NSDate date];
        NSTimeInterval diff = autoRefreshInterval - [now timeIntervalSinceDate:lastRefreshDate];
        if (diff < 0) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;            
            diff = 2.0;
        }
        [self setNextTimer:diff];
    }

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
    if (settingsView) return;
    
    settingsView = [[[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil] autorelease];
    UINavigationController *parentNav = [[[UINavigationController alloc] initWithRootViewController:settingsView] autorelease];
        
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
    [nav presentModalViewController:parentNav animated:YES];
}

- (void)closeSettingsView
{
    settingsView = nil;
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];    
    [(FriendsTimelineController*)[nav topViewController] reload:self];
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
        [self.postView post];
    }
}

- (void)search:(NSString*)query
{
    int previousTab = tabBarController.selectedIndex;
    tabBarController.selectedIndex = TAB_SEARCH;
    UINavigationController *nav = [[tabBarController viewControllers] objectAtIndex:TAB_SEARCH];
    [nav popToRootViewControllerAnimated:(previousTab == TAB_SEARCH)];
    SearchViewController *search = (SearchViewController*)[nav.viewControllers objectAtIndex:0];
    [search search:query];
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
static NSString *urlRegexp  = @"(((http(s?))\\:\\/\\/)([-0-9a-zA-Z]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/[-0-9a-zA-Z_#!:.?+=&%@~*\\';,/$]*)?)";
static NSString *endRegexp  = @"[.,;:]$";
static NSString *nameRegexp = @"(@[0-9a-zA-Z_]+)";
static NSString *hashRegexp = @"(#[-a-zA-Z0-9_.+:=]+)";

- (void)openLinksViewController:(NSString*)text
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
    
    BOOL hasHash = false;
    
    NSMutableArray *links = [NSMutableArray array];
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *tmp = text;

    // Find URLs
    while ([tmp matches:urlRegexp withSubstring:array]) {
        NSString *url = [array objectAtIndex:0];
        [array removeAllObjects];
        if ([url matches:endRegexp withSubstring:array]) {
            url = [url substringToIndex:[url length] - 1];
        }
        [links addObject:url];
        NSRange r = [tmp rangeOfString:url];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }

    // Find screen names
    tmp = text;
    while ([tmp matches:nameRegexp withSubstring:array]) {
        NSString *username = [array objectAtIndex:0];
        [links addObject:username];
        NSRange r = [tmp rangeOfString:username];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
    }

    // Find hashtags
    tmp = text;
    while ([tmp matches:hashRegexp withSubstring:array]) {
        NSString *hash = [array objectAtIndex:0];
        [links addObject:hash];
        NSRange r = [tmp rangeOfString:hash];
        tmp = [tmp substringFromIndex:r.location + r.length];
        [array removeAllObjects];
        hasHash = true;
    }
  
    if ([links count] == 1) {
        NSString* url = [links objectAtIndex:0];
        NSRange r = [url rangeOfString:@"http://"];
        if (r.location != NSNotFound) {
            [self openWebView:url on:nav];
        }
        else {
            if (hasHash) {
                [self search:[links objectAtIndex:0]];
            }
            else {
                UserTimelineController *userTimeline = [[[UserTimelineController alloc] init] autorelease];
                NSString *screenName = [links objectAtIndex:0];
                [userTimeline loadUserTimeline:[screenName substringFromIndex:1]];
                [nav pushViewController:userTimeline animated:true];
            }
        }
    }
    else {
        nav.navigationBar.tintColor = nil;
        
        LinkViewController* linkView = [[[LinkViewController alloc] init] autorelease];
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
    Status* status;
    if (isDirectMessage) {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_MESSAGES];
        status = [Status statusWithJsonDictionary:dic type:TWEET_TYPE_SENT];
    }
    else {
        nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];
        status = [Status statusWithJsonDictionary:dic type:TWEET_TYPE_FRIENDS];
    }
    [status insertDB];
    FriendsTimelineController *c = (FriendsTimelineController*)[nav.viewControllers objectAtIndex:0];
    [c postTweetDidSucceed:status];
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
- (void)messageDidDelete:(TwitterClient*)client obj:(NSObject*)obj
{
    Status* sts = (Status*)client.context;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 statusId = [[dic objectForKey:@"id"] longLongValue];        
        if (sts.statusId == statusId) {
            [sts deleteFromDB];
        }
    }
    [sts release];
}

//
// Handle favorites
//
- (void)toggleFavorite:(Status*)status
{
    TwitterClient *client = [[TwitterClient alloc] initWithTarget:self action:@selector(favoriteDidChange:obj:)];
    client.context = [status  retain];
    [client favorite:status];
}

- (void)favoriteDidChange:(TwitterClient*)sender obj:(NSObject*)obj
{
    Status* sts = sender.context;
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = (NSDictionary*)obj;
        sqlite_int64 statusId = [[dic objectForKey:@"id"] longLongValue];
        if (sts.statusId != statusId) {
            NSLog(@"Someting wrong with contet. Ignore error...");
            return;
        }
        BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
        sts.favorited = favorited;
        [sts updateFavoriteState];
        
        UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
        UIViewController *c = nav.topViewController;
        if ([c respondsToSelector:@selector(toggleFavorite:status:)]) {
            [c toggleFavorite:favorited status:sts];
        }
        
        c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(updateFavorite:)]) {
            [c updateFavorite:sts];
        }
    }
    [sts release];
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    Status* sts = sender.context;
    
    if (sender.request == TWITTER_REQUEST_FAVORITE ||
        sender.request == TWITTER_REQUEST_DESTROY_FAVORITE) {
        if (sender.statusCode == 404 || sender.statusCode == 403) {
            BOOL favorited = (sender.request == TWITTER_REQUEST_FAVORITE) ? true : false;
            sts.favorited = favorited;
            [sts updateFavoriteState];
            UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
            UIViewController *c = nav.topViewController;
            if ([c respondsToSelector:@selector(toggleFavorite:status:)]) {
                [c toggleFavorite:favorited status:sts];
            }
        }
    }
    else {
        if (sender.statusCode == 404) {
            [sts deleteFromDB];
        }
        else {
            [self alert:error message:detail];
        }
    }

    [sts release];
}

//
// Common utilities
//

static UIAlertView *sAlert = nil;

- (void)alert:(NSString*)title message:(NSString*)message
{
    if (sAlert) return;
    
    sAlert = [[UIAlertView alloc] initWithTitle:title
                                        message:message
                                        delegate:self
                               cancelButtonTitle:@"Close"
                               otherButtonTitles:nil];
    [sAlert show];
    [sAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonInde
{
    sAlert = nil;
}

+(TwitterFonAppDelegate*)getAppDelegate
{
    return (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
}

@end

