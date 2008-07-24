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
    NSString*           url;
    BOOL                needsReload;
}

- (void)setUrl:(NSString*)aUrl;

- (IBAction)reload:(id)sender;

@end
