//
//  TwitterFonAppDelegate.m
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"
#import "ColorUtils.h"

@interface TwitterFonAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
@end

@interface NSObject (TimelineViewControllerDelegate)
- (void)postTweetDidSucceed:(NSDictionary*)dic;
- (void)didChangeSeletViewController:(UINavigationController*)navigationController;
@end

@implementation TwitterFonAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize postView;
@synthesize webView;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    // The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    [self createEditableCopyOfDatabaseIfNeeded];

#if 0 // for debugging
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
#endif
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    //NSLog(@"%@ %@", username, password);

    if (username == nil || password == nil ||
        [username compare:@""] == 0 ||
        [password compare:@""] == 0) {
        tabBarController.selectedIndex = TAB_SETTINGS;
    }
    else {
        tabBarController.selectedIndex = TAB_FRIENDS;
    }
    
    selectedTab = 0;
   
	[window addSubview:tabBarController.view];
    [UIColor initTwitterFonColorScheme];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [postView saveTweet];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [postView checkProgressWindowState];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [postView saveTweet];
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	[super dealloc];
}

//
// UITabBarControllerDelegate
//
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
    if (selectedTab != TAB_SETTINGS) {
        UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:selectedTab];
        UIViewController *c = [nav.viewControllers objectAtIndex:0];
        if ([c respondsToSelector:@selector(didChangeSeletViewController:)]) {
            [c didChangeSeletViewController:nav];
        }
    }
    selectedTab = tabBar.selectedIndex;
}


// Bypass posted message to friends timeline view...
//
- (void)postTweetDidSucceedDelegate:(NSDictionary*)dic
{
    UINavigationController* nav = (UINavigationController*)[tabBarController.viewControllers objectAtIndex:TAB_FRIENDS];
    UIViewController *c = [nav.viewControllers objectAtIndex:0];;
    [c postTweetDidSucceed:dic];
    
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
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"db1.1.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db1.1.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end

