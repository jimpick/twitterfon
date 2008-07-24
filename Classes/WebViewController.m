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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (animated && needsReload) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        self.title = url;
        [self setUrlBar:url];
    }
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

- (void)setUrlBar:(NSString*)aUrl
{
    [button setTitle:[NSString stringWithFormat:@"  %@", aUrl] forState:UIControlStateDisabled];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
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
    NSURL *aUrl = aWebView.request.mainDocumentURL;
    [self setUrlBar:aUrl.absoluteString];
    backButton.enabled = (webView.canGoBack) ? true : false;
    forwardButton.enabled = (webView.canGoForward) ? true : false;
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
}

- (void)setUrl:(NSString*)aUrl
{
    needsReload = ([url compare:aUrl] == 0)  ? false : true;
    url = [aUrl copy];
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;
    
    [[self navigationController].view addSubview:postView.view];
    UIViewController *c = [self.navigationController.viewControllers objectAtIndex:0];
    [postView startEditWithString:[NSString stringWithFormat:@" %@", url] insertAfter:TRUE setDelegate:c];
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [url release];
	[super dealloc];
}


@end
