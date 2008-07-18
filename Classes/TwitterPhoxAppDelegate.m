//
//  TwitterPhoxAppDelegate.m
//  TwitterPhox
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import "TwitterPhoxAppDelegate.h"


@interface NSObject (TimelineViewControllerDelegate)
- (void)didSelectViewController:(int)sender;
@end 


@implementation TwitterPhoxAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {

#if 0 // for debugging
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
#endif
	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];

    //NSLog(@"%@ %@", username, password);

    if (username == nil || password == nil) {
        tabBarController.selectedIndex = 4;
    }
    else {
        tabBarController.selectedIndex = 1;
    }
    
	[window addSubview:tabBarController.view];
}

- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController {
    if ([viewController respondsToSelector:@selector(didSelectViewController:)]) {
        [viewController didSelectViewController:tabBar.selectedIndex];
    }
}

/*
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

