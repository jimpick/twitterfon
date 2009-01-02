//
//  WebViewController.h
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIActionSheetDelegate> {
    IBOutlet UIWebView* webView;
    IBOutlet UILabel*   titleLabel;
    IBOutlet UIToolbar* toolbar;

    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *forwardButton;
    
    NSMutableDictionary*    tinyURLStore;
    NSString*               url;
    NSURL*                  openingURL;
    NSURL*                  currentURL;
    BOOL                    needsToDecodeTinyURL;
}

@property(nonatomic, retain) NSURL* currentURL;

- (void)setUrl:(NSString*)aUrl;

- (IBAction)goBack: (id)sender;
- (IBAction)goForward: (id)sender;
- (IBAction)onAction: (id)sender;

- (IBAction)reload:(id)sender;
- (IBAction)stop:(id)sender;

@end
