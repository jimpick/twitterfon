//
//  WebViewController.m
//  TwitterFon
//
//  Created by kaz on 7/23/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import "TwitterFonAppDelegate.h"
#import "StringUtil.h"

#define kAnimationKey @"transitionViewAnimation"

typedef enum {
    BUTTON_RELOAD,
    BUTTON_STOP,
} ToolbarButton;

@interface WebViewController (Private)
- (void)updateToolbar:(ToolbarButton)state;
@end;

@implementation WebViewController

@synthesize currentURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
            tinyURLStore = [[NSMutableDictionary alloc] init];
  	}
  	return self;
}

- (void)viewDidLoad
{
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(postTweet:)];
    self.navigationItem.rightBarButtonItem = postButton;

    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.tintColor = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    
    if (animated) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        titleLabel.text = url;
        self.currentURL = [NSURL URLWithString:url];
    }
    [self updateToolbar:BUTTON_STOP];
    
    self.navigationController.navigationBar.topItem.titleView = titleLabel;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [webView loadHTMLString:@"<html><style>html { width:320px; height:480px; background-color:white; }</style><body></body></html>" baseURL:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrient
{
    [self.navigationController setNavigationBarHidden:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) animated:true];
}

- (void)updateToolbar:(ToolbarButton)button
{
    UIBarButtonItem *newItem;

    if (button == BUTTON_STOP) {
        newItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)] autorelease];
    }
    else {
        newItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)] autorelease];
    }
    
    NSMutableArray *items = [toolbar.items mutableCopy];
    [items replaceObjectAtIndex:5 withObject:newItem];
    [toolbar setItems:items animated:false];
    
    [items release];

    // workaround to change toolbar state
    backButton.enabled = true;
    forwardButton.enabled = true;
    backButton.enabled = false;
    forwardButton.enabled = false;
    
    backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
    
    
}

- (IBAction)reload:(id)sender
{
    [webView reload];
    [self updateToolbar:BUTTON_STOP];
}

- (IBAction)stop:(id)sender
{
    [webView stopLoading];
    [self updateToolbar:BUTTON_RELOAD];
}

- (IBAction) goBack:(id)sender
{
    [webView goBack];
}

- (IBAction) goForward:(id)sender
{
    [webView goForward];
}

- (IBAction) onAction:(id)sender
{
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Open with Safari", @"Email This Link", nil];
    [as showInView:self.navigationController.parentViewController.view];
    [as release];
    
}

- (void)actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (as.cancelButtonIndex == buttonIndex) return;

    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:currentURL];
    }
    else {
        NSString *body = @"\n\nSent from <a href=\"http://twitterfon.net\">TwitterFon</a>";
        
        NSString *mailTo = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@%@",
                            [titleLabel.text encodeAsURIComponent],
                            currentURL,
                            [body encodeAsURIComponent]];
        NSLog(@"%@", mailTo);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailTo]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:openingURL];
    }
}


#define NUM_SCHEMES     5

static NSString *schemes[NUM_SCHEMES][2] = {
    {@"http://maps.google.com/", @"Maps"},
    {@"http://www.youtube.com/", @"YouTube"},
    {@"http://phobos.apple.com/", @"iTunes"},
    {@"mailto:", @"Mail"},
    {@"tel:", @"Phone"},
};

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [openingURL release];
    openingURL = [request.URL copy];
    self.currentURL = [request.mainDocumentURL absoluteURL];
    
    NSString *aURL = [currentURL absoluteString];
    titleLabel.text = aURL;
    
    for (int i = 0; i < NUM_SCHEMES; ++i) {
        NSRange r = [aURL rangeOfString:schemes[i][0]];
        if (r.location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TwitterFon"
                                                            message:[NSString stringWithFormat:@"You are opening %@", schemes[i][1]]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Open", nil];
            [alert show];	
            [alert release];
            return false;
        }
    }
   
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [self updateToolbar:BUTTON_STOP];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Remove all a tag target
    titleLabel.text = [aWebView stringByEvaluatingJavaScriptFromString:
                  @"try {var a = document.getElementsByTagName('a'); for (var i = 0; i < a.length; ++i) { a[i].setAttribute('target', '');}}catch (e){}; document.title"];
    
    NSURL *aURL = aWebView.request.mainDocumentURL;
    self.currentURL = aURL;
    [self updateToolbar:BUTTON_RELOAD];
    
    if (needsToDecodeTinyURL) {
        [tinyURLStore setValue:url forKey:aURL.absoluteString];
        needsToDecodeTinyURL = false;
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] <= NSURLErrorBadURL) {
        [[TwitterFonAppDelegate getAppDelegate] alert:@"Failed to load the page" message:[error localizedDescription]];
    }
    [self updateToolbar:BUTTON_RELOAD];
}

- (void)setUrl:(NSString*)aUrl
{
    NSRange r = [aUrl rangeOfString:@"http://tinyurl.com"];
    needsToDecodeTinyURL = (r.location != NSNotFound) ? true : false;
    url = [aUrl copy];
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    NSString *aURL = [currentURL absoluteString];
    NSString *decoded = [tinyURLStore valueForKey:aURL];
    
    [postView editWithURL:(decoded) ? decoded : aURL];
    
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}


- (void)dealloc {
    [openingURL release];
    [currentURL release];
    [tinyURLStore release];
    [url release];
	[super dealloc];
}


@end
