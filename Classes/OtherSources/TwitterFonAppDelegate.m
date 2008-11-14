//
//  TwitterFonAppDelegate.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "TimelineViewController.h"
#import "DBConnection.h"
#import "ColorUtils.h"

@interface TwitterFonAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
@end

@interface NSObject (TimelineViewControllerDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)dic;
- (void)postViewAnimationDidFinish;
- (void)didLeaveTab:(UINavigationController*)navigationController;
- (void)didSelectTab:(UINavigationController*)navigationController;
- (void)imageStoreDidGetNewImage:(UIImage*)image;
@end

@implementation TwitterFonAppDelegate

@synthesize postView;
@synthesize imageStore;
@synthesize selectedTab;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    [self createEditableCopyOfDatabaseIfNeeded];

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    imageStore = [[ImageStore alloc] initWithDelegate:self];    
    postView = nil;

    selectedTab = 0;
    tabBarController.selectedIndex = TAB_FRIENDS;
    
	[window addSubview:tabBarController.view];
    [UIColor initTwitterFonColorScheme];
    
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [imageStore didReceiveMemoryWarning];
}

- (void)openSettingsView
{
    if (settings == nil) {
        settings = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
    
        UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:0];
        [nav presentModalViewController:settings animated:YES];
    }
}

- (void)closeSettingsView
{
    [settings release];
    settings = nil;
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
    [self.postView startEdit];
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

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:MAIN_DATABASE_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

//
// Bypass posted message to friends timeline view...
//
- (void)postTweetDidSucceed:(NSDictionary*)dic
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];
    UIViewController *c = [nav.viewControllers objectAtIndex:0];;
    [c postTweetDidSucceed:dic];
}

- (void)postViewAnimationDidFinish:(BOOL)didPost
{
    if (didPost && selectedTab == TAB_FRIENDS) {
        UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];    
        UIViewController *c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(postViewAnimationDidFinish)]) {
            [c postViewAnimationDidFinish];
        }
    }
}

@end

