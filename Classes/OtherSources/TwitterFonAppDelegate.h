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

typedef enum {
    TAB_FRIENDS,
    TAB_REPLIES,
    TAB_MESSAGES,
    TAB_SETTINGS,
} TAB_ITEM;

@interface TwitterFonAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	IBOutlet UIWindow*              window;
	IBOutlet UITabBarController*    tabBarController;
    IBOutlet PostViewController*    postView;
    IBOutlet WebViewController*     webView;
}

@property (nonatomic, retain) UIWindow*             window;
@property (nonatomic, retain) UITabBarController*   tabBarController;
@property (nonatomic, retain) PostViewController*   postView;
@property (nonatomic, retain) WebViewController*    webView;

@end
