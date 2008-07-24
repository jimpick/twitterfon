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

@implementation WebViewController

@synthesize url;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


- (void)viewDidLoad
{
    UIImage *image = [UIImage imageNamed:@"postbutton.png"];
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithImage:image 
                                                           style:UIBarButtonItemStylePlain 
                                                           target:self
                                                           action:@selector(postTweet:)];
    self.navigationItem.rightBarButtonItem = postButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (animated) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        self.title = url;
    }
}


- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;
    
    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithString:url insertAfter:TRUE setDelegate:self];
    
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
