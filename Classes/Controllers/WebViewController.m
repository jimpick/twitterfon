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
#import "PostViewController.h"

#define kAnimationKey @"transitionViewAnimation"

@interface WebViewController(Private)
- (void)setUrlBar:(NSString*)aUrl;
@end


@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

- (void)viewDidLoad
{
    UIImage *image = [UIImage imageNamed:@"postbutton.png"];
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithImage:image 
                                                           style:UIBarButtonItemStylePlain 
                                                           target:self
                                                           action:@selector(postTweet:)];
    self.navigationItem.rightBarButtonItem = postButton;
    needsReload = false;
    button.font = [UIFont systemFontOfSize:14];
    button.lineBreakMode = UILineBreakModeTailTruncation;
    
    url = [[NSString alloc] init];
    tinyURLStore = [[NSMutableDictionary alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
    
    if (animated && needsReload) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        self.title = url;
        [self setUrlBar:url];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [webView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [webView loadHTMLString:@"<html><style>html { width:320px; height:480px; background-color:white; }</style><body></body></html>" baseURL:nil];
}

- (IBAction)reload:(id)sender
{
    [webView reload];
}

- (IBAction) goBack:(id)sender
{
    [webView goBack];
}

- (IBAction) goForward:(id)sender
{
    [webView goForward];
}

- (IBAction) openSafari: (id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)setUrlBar:(NSString*)aUrl
{
    [button setTitle:[NSString stringWithFormat:@"  %@", aUrl] forState:UIControlStateDisabled];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:openingURL];
    }
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [openingURL release];
    openingURL = [request.URL copy];
    NSString *aURL = [request.URL absoluteString];
    self.title = aURL;
    [self setUrlBar:aURL];
    
    NSRange r = [aURL rangeOfString:@"http://maps.google.com/"];
    if (r.location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TwitterFon"
                                                        message:@"You are opening Google Maps"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Open", nil];
        [alert show];	
        [alert release];
        return false;
    }
    
    r = [aURL rangeOfString:@"http://www.youtube.com/"];
    if (r.location != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TwitterFon"
                                                        message:@"You are opening YouTube"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Open", nil];
        [alert show];	
        [alert release];
        return false;
    }
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURL *aURL = aWebView.request.mainDocumentURL;
    [self setUrlBar:aURL.absoluteString];
    backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
    
    if (needsToDecodeTinyURL) {
        [tinyURLStore setValue:url forKey:aURL.absoluteString];
        needsToDecodeTinyURL = false;
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([error code] <= NSURLErrorBadURL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to load the page"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];	
        [alert release];
    }
}

- (void)setUrl:(NSString*)aUrl
{
//    needsReload = ([url compare:aUrl] == 0)  ? false : true;
    needsReload = true;
    NSRange r = [aUrl rangeOfString:@"http://tinyurl.com"];
    needsToDecodeTinyURL = (r.location != NSNotFound) ? true : false;
    url = [aUrl copy];
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;

    NSString *aURL = webView.request.URL.absoluteString;
    NSString *decoded = [tinyURLStore valueForKey:aURL];
    
    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithURL:(decoded) ? decoded : aURL];
    
}

- (void)didReceiveMemoryWarning {
    [webView stopLoading];    
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [openingURL release];
    [tinyURLStore release];
    [url release];
	[super dealloc];
}


@end
