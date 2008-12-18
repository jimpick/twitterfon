//
//  TwitterFonAppDelegate.h
//  TwitterFon
//
//  Created by kaz on 7/13/08.
//  Copyright naan studio 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostViewController.h"
#import "WebViewController.h"
#import "SettingsViewController.h"
#import "ImageStore.h"
#import "Status.h"

typedef enum {
    TAB_FRIENDS,
    TAB_REPLIES,
    TAB_MESSAGES,
    TAB_SEARCH,
} TAB_ITEM;

@interface TwitterFonAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow*              window;
	IBOutlet UITabBarController*    tabBarController;

    PostViewController*             postView;
    WebViewController*              webView;
    SettingsViewController*         settingsView;
    ImageStore*                     imageStore;
    int                             selectedTab;

    NSTimeInterval                  autoRefreshInterval;
    NSTimer*                        autoRefreshTimer;
    NSDate*                         lastRefreshDate;
}

- (IBAction)post:(id)sender;

- (void)postTweetDidSucceed:(NSDictionary*)status isDirectMessage:(BOOL)isDirectMessage;
- (void)postViewAnimationDidFinish:(BOOL)isDirectMessage;

- (void) openSettingsView;
- (void) closeSettingsView;
- (void) openWebView:(NSString*)url on:(UINavigationController*)viewController;
- (void) openWebView:(NSString*)url;
- (void) search:(NSString*)query;

- (void)openLinksViewController:(NSString*)text;
- (void)toggleFavorite:(Status*)status;

- (void)alert:(NSString*)title message:(NSString*)detail;

+ (TwitterFonAppDelegate*)getAppDelegate;

@property (nonatomic, readonly) UIWindow*           window;
@property (nonatomic, assign) PostViewController*   postView;
@property (nonatomic, readonly) ImageStore*         imageStore;
@property (nonatomic, assign) int                   selectedTab;

@end
