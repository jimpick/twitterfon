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
    NSString*           url;
    BOOL                needsReload;
}

- (void)setUrl:(NSString*)aUrl;

@end
