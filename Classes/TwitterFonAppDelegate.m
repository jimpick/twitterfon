//
//  TwitterPhoxAppDelegate.m
//  TwitterPhox
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterFonAppDelegate.h"


@interface NSObject (TimelineViewControllerDelegate)
- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username;
@end

@interface NSObject (PostViewControllerDelegate)
- (void)didSelectViewController:(UITabBarController*)tabBar username:(NSString*)username;
- (void)didLeaveViewController;
- (void)loadTimeline;
@end

@interface TwitterFonAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
@end

@implementation TwitterFonAppDelegate

@synthesize window;
@synthesize tabBarController;


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
	username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
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
    previousViewIndex = tabBarController.selectedIndex;
/*    
    for (int i = 0; i < [tabBarController.viewControllers count]; ++i) {
        UIViewController *v = [tabBarController.viewControllers objectAtIndex:i];
       if ([v respondsToSelector:@selector(loadTimeline)]) {
           [v loadTimeline];
       }
    }
*/    
	[window addSubview:tabBarController.view];
}

- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController {
    if ([viewController respondsToSelector:@selector(didSelectViewController:username:)]) {
        [viewController didSelectViewController:tabBar username:username];
    }
    UIViewController *prev = [[tabBar viewControllers] objectAtIndex:previousViewIndex];
    if ([prev respondsToSelector:@selector(didLeaveViewController)]) {
        [prev didLeaveViewController];
    }
    previousViewIndex = tabBar.selectedIndex;
}

- (void)dealloc
{
	[tabBarController release];
	[window release];
	[super dealloc];
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
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"db.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"db.sql"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end

