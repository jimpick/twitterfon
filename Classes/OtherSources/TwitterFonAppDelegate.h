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
#import "ImageStore.h"

typedef enum {
    TAB_FRIENDS,
    TAB_REPLIES,
    TAB_MESSAGES,
    TAB_SETTINGS,
} TAB_ITEM;

@interface TwitterFonAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow*              window;
	IBOutlet UITabBarController*    tabBarController;

    PostViewController*             postView;
    WebViewController*              webView;
    ImageStore*                     imageStore;
    int                             selectedTab;
}

- (void) openWebView:(NSString*)url on:(UINavigationController*)viewController;

@property (nonatomic, assign) PostViewController*   postView;
@property (nonatomic, assign) ImageStore*           imageStore;

@end
