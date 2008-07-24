//
//  WebViewController.h
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController {
    IBOutlet UIWebView* webView;
    IBOutlet UIButton*  button;

    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *forwardButton;
    
    NSString*           url;
    BOOL                needsReload;
}

- (void)setUrl:(NSString*)aUrl;

- (IBAction)reload:(id)sender;
- (IBAction)goBack: (id)sender;
- (IBAction)goForward: (id)sender;

@end
