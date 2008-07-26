#import <QuartzCore/QuartzCore.h>
#import "TimelineViewController.h"
#import "TwitterFonAppDelegate.h"
#import "WebViewController.h"
#import "PostViewController.h"
#import "MessageCell.h"
#import "ColorUtils.h"
#import "StringUtil.h"
#import "REString.h"

@interface NSObject (TimelineViewControllerDelegate)
- (void)postTweetDidSucceed:(Message*)message;
@end

@implementation TimelineViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
    
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    unread   = 0;
    tag      = [self navigationController].tabBarItem.tag;
	username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];

    switch (tag) {
        case TAB_FRIENDS:
            self.tableView.separatorColor = [UIColor friendColorBorder];
            break;
            
        case TAB_REPLIES:
            self.tableView.separatorColor =  [UIColor repliesColorBorder];
            self.tableView.backgroundColor = [UIColor repliesColor];
            break;
            
        case TAB_MESSAGES:
            self.tableView.separatorColor =  [UIColor messageColorBorder];
            self.tableView.backgroundColor = [UIColor messageColor];
    }
    [timeline restore:tag];
    [timeline update:tag];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated 
{
    if (!animated) {
        [self navigationController].tabBarItem.badgeValue = nil;
        for (int i = 0; i < [timeline countMessages]; ++i) {
            Message* m = [timeline messageAtIndex:i];
            m.unread = false;
        }
        unread = 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [timeline countMessages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MessageCell* cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:MESSAGE_REUSE_INDICATOR];
	Message* m = [timeline messageAtIndex:indexPath.row];
	if (!cell) {
		cell = [[[MessageCell alloc] initWithFrame:CGRectZero reuseIdentifier:MESSAGE_REUSE_INDICATOR] autorelease];
	}
    
	cell.message = m;
    cell.imageView.row = indexPath.row;
    [cell.imageView setImage:[imageStore getImage:m.user delegate:self] forState:UIControlStateNormal];
    [cell.imageView addTarget:self action:@selector(didTouchProfileImage:) forControlEvents:UIControlEventTouchUpInside];
    
    if (tag == TAB_FRIENDS) {
        NSString *str = [NSString stringWithFormat:@"@%@", username];
        NSRange r = [m.text rangeOfString:str];
        if (r.location != NSNotFound) {
            cell.contentView.backgroundColor = [UIColor repliesColor:m.unread];
        }
        else {
            cell.contentView.backgroundColor = [UIColor friendColor:m.unread];
        }
    }
    else if (tag == TAB_REPLIES) {
        cell.contentView.backgroundColor = [UIColor repliesColor:m.unread];
    }
    else if (tag == TAB_MESSAGES) {
        cell.contentView.backgroundColor = [UIColor messageColor:m.unread];
    }
    
	[cell update];

	return cell;
}

- (void)didTouchProfileImage:(id)sender
{
    ProfileImageButton *button = (ProfileImageButton*)sender;
    Message* m = [timeline messageAtIndex:button.row];
    
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;
    
    if (postView.view.hidden == false) return;
    
    NSString *msg;
    if (tag == MSG_TYPE_MESSAGES) {
        msg = [NSString stringWithFormat:@"d %@ ", m.user.screenName];
    }
    else {
        msg = [NSString stringWithFormat:@"@%@ ", m.user.screenName];
    }
    
    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithString:msg insertAfter:FALSE setDelegate:self];
}

- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}

- (IBAction) post: (id) sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;

    [[self navigationController].view addSubview:postView.view];
    [postView startEditWithDelegate:self];
}

- (IBAction) reload: (id) sender
{
    [timeline update:tag];
}


//
// UITableViewDelegate
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    return m.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *m = [timeline messageAtIndex:indexPath.row];
    if (!m) return;
    NSString *pat = @"(((http(s?))\\:\\/\\/)([0-9a-zA-Z\\-]+\\.)+[a-zA-Z]{2,6}(\\:[0-9]+)?(\\/([0-9a-zA-Z_#!:.?+=&%@~*\';,\\-\\/\\$])*)?)";
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
    if ([m.text matches:pat withSubstring:array]) {

        TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        WebViewController *webView = appDelegate.webView;
        
        webView.hidesBottomBarWhenPushed = YES;
        [webView setUrl:[array objectAtIndex:0]];
        [[self navigationController] pushViewController:webView animated:YES];
    }
}

- (void)postViewAnimationDidFinish:(BOOL)didPost
{
    if (didPost && tag == TAB_FRIENDS &&
        self.navigationController.topViewController == self) {
        //
        // Do animation if the controller displays friends timeline.
        //
        NSArray *indexPaths = [[NSArray arrayWithObjects:[[NSIndexPath indexPathForRow:0 inSection:0] autorelease], nil] autorelease];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)postTweetDidSucceed:(NSDictionary*)dic
{
    if (tag == TAB_MESSAGES) {
        return;
    }
    
    Message *message = [Message messageWithJsonDictionary:dic type:MSG_TYPE_FRIENDS];
    
    if (tag == TAB_FRIENDS) {
        [timeline insertMessage:message];
    }
    else if (tag == TAB_REPLIES) {
        //
        //  If the controller doesn't handle friends timeline, pass the message to app delegate then
        // app delegate passes the message to friends timeline view controller.
        //
        // If the view controller is direct messages, do nothing.
        //
        NSObject *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
        if (appDelegate && [appDelegate respondsToSelector:@selector(postTweetDidSucceed:)]) {
            [appDelegate postTweetDidSucceed:message];
        }
    }
}

//
// UITabBarControllerDelegate
//
- (void)tabBarController:(UITabBarController *)tabBar didSelectViewController:(UIViewController *)viewController
{
}

//
// ImageStoreDelegate
//
- (void)imageStoreDidGetNewImage:(UIImage*)image
{
	[self.tableView reloadData];
}

//
// TimelineDownloaderDelegate
//
- (void)timelineDidReceiveNewMessage:(Message*)msg
{
	[imageStore getImage:msg.user delegate:self];
}

- (void)timelineDidUpdate:(int)count
{
    unread += count;
    [self navigationController].tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", unread];

    if (!self.view.hidden) {
        NSMutableArray *indexPath = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < count; ++i) {
            [indexPath addObject:[[NSIndexPath indexPathForRow:i inSection:0] autorelease]];
        }        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPath withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];    
    }

}
@end
