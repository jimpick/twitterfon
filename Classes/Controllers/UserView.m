//
//  UserView.m
//  TwitterFon
//
//  Created by kaz on 11/16/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserView.h"
#import "QuartzUtils.h"

#define kMessageUserProtected @"This user has protected their updates."
#define kMessageDetail        @"You need to send a request before you can start following this person."

#define kRemoveButtonAnim @"removeButtonAnimation"
#define kFollowButtonAnim @"followButtonAnimation"
#define kMessageFlashAnim @"messageFlashAnimation"

@interface NSObject (UserViewDelegate)
- (void)requestFriendship:(BOOL)createOrDestroy;
@end


@implementation UserView

@synthesize profileImage;
@synthesize user;
@synthesize protected;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    UIImage *back = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(back.CGImage);
    lockIcon = [[UIImage imageNamed:@"lock.png"] retain];

    url = [UIButton buttonWithType:UIButtonTypeCustom];
    url.frame = CGRectMake(93, 77, 217, 18);
    url.font = [UIFont boldSystemFontOfSize:14];  	
    [url setTitleColor:[UIColor colorWithRed:0.208 green:0.310 blue:0.518 alpha:1.0] forState:UIControlStateNormal];
    [url setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [url setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    url.lineBreakMode = UILineBreakModeTailTruncation;
    url.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    url.titleShadowOffset = CGSizeMake(0, 1);
    [self addSubview:url];
    
    followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    followButton.frame = CGRectMake(9, 104, 75, 32);
    [followButton addTarget:self action:@selector(didTouchFollowButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:followButton];
    
    buttonState = FOLLOW_BUTTON_NOT_LOADED;
    
    protected = false;
    
    return self;
}

-(void)dealloc
{
    if (twitterClient) {
        [twitterClient cancel];
        [twitterClient release];
    }
    if (timer) {
        [timer invalidate];
    }
    CGImageRelease(background);
    [profileImage release];
    [lockIcon release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

  	CGContextDrawImage(context, rect, background);

    CGContextSetShadowWithColor(context, CGSizeZero, 0, [[UIColor whiteColor] CGColor]);
    
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    if (profileImage) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    }
    else {
        CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1.0);
    }
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    // Add Rect to the current path, then stroke it
    CGContextAddRect(context, CGRectMake(10.0, 20.0, 73.0, 73.0));
    CGContextStrokePath(context);    
    CGContextAddRect(context, CGRectMake(10.0, 20.0, 73.0, 73.0));
    CGContextFillPath(context);  

    if (profileImage) {
        [profileImage drawAtPoint:CGPointMake(10.0, 20.0)];
    }
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    
    if (protected) {
        [kMessageUserProtected drawInRect:CGRectMake(93, 16, 189, 44) withFont:[UIFont boldSystemFontOfSize:16]];
        [kMessageDetail drawInRect:CGRectMake(93, 59, 217, 36) withFont:[UIFont systemFontOfSize:14]];
    }
    else {
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
        
        [user.name drawInRect:CGRectMake(93, 20, 189, 44) withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation];
        [user.location drawInRect:CGRectMake(93, 59, 217, 18) withFont:[UIFont systemFontOfSize:14]];
        
        if (user.followersCount > 0) {
            NSString *numFollowers;
            if (user.followersCount == 1) {
                numFollowers = @"1 follower";
            }
            else {
                numFollowers = [NSString stringWithFormat:@"%d followers", user.followersCount];
            }
            [[UIColor darkGrayColor] set];
            [numFollowers drawInRect:CGRectMake(93, 42, 217, 21) withFont:[UIFont systemFontOfSize:13]];
        }
        
        if (user.protected) {
            [lockIcon drawAtPoint:CGPointMake(298, 22)];
        }
    }
}

-(void)setUser:(User*)aUser delegate:(id)delegate
{
    user = aUser;
    
    [url setTitle:user.url forState:UIControlStateNormal];
    [url setTitle:user.url forState:UIControlStateHighlighted];

    [url addTarget:delegate action:@selector(didTouchURL:) forControlEvents:UIControlEventTouchUpInside];   

	NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];    
    if (buttonState == FOLLOW_BUTTON_NOT_LOADED &&
        ![username isEqualToString:user.screenName]) {
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(friendshipDidCheck:messages:)];
        [twitterClient existFriendship:user.screenName];
    }

    [self setNeedsDisplay];
}


- (void)friendshipDidCheck:(TwitterClient*)sender messages:(NSObject*)obj
{
    NSNumber *flag = (NSNumber*)obj;
    [self setFriendship:[flag boolValue]];
    [sender autorelease];
    twitterClient = nil;
}

- (void)setAnimation:(UIView*)view forKey:(NSString*)key
{
    CATransition *animation = [CATransition animation];
    
    [animation setType:kCATransitionFade];
    [animation setDuration:0.3];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[view layer] addAnimation:animation forKey:key];    
}

- (void)clearMessage:(NSTimer*)aTimer userInfo:(NSObject*)obj
{
    messageLabel.hidden = true;
    [self setAnimation:messageLabel forKey:kMessageFlashAnim];
    timer = nil;
}

- (void)flashMessage
{
    NSString *fmt = (following) ? @"You are now following %@." : @"You are no longer following %@.";
    NSString *msg = [NSString stringWithFormat:fmt, user.screenName];

    if (!messageLabel) {
        messageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(93, 110, 217, 20)] autorelease];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.font = [UIFont systemFontOfSize:13];
        messageLabel.shadowColor = [UIColor whiteColor];
        messageLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:messageLabel];
    }
    messageLabel.hidden = false;
    messageLabel.text = msg;
    [self setAnimation:messageLabel forKey:kMessageFlashAnim];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                             target:self 
                                           selector:@selector(clearMessage:userInfo:)
                                           userInfo:nil
                                            repeats:false];
}

- (void)followDidRequest:(TwitterClient*)sender messages:(NSObject*)obj
{
    [self setFriendship:(sender.request == TWITTER_REQUEST_CREATE_FRIENDSHIP) ? true : false];
    [sender autorelease];
    twitterClient = nil;
    [self flashMessage];
    followButton.enabled = true;
}

- (void)twitterClientDidFail:(TwitterClient*)sender error:(NSString*)error detail:(NSString*)detail
{
    if (sender.request != TWITTER_REQUEST_FRIENDSHIP_EXISTS) {
        [self setFriendship:!following];
        [self flashMessage];
        followButton.enabled = true;
    }
    [sender autorelease];
    twitterClient = nil;
}

- (void)didTouchFollowButton:(id)sender
{
    if (buttonState == FOLLOW_BUTTON_FOLLOWING) {
        
        [followButton setImage:[UIImage imageNamed:@"remove.png"] forState:UIControlStateNormal];
        [self setAnimation:followButton forKey:kRemoveButtonAnim];
        buttonState = FOLLOW_BUTTON_REMOVE;
    }
    else {
        if (twitterClient) {
            return;
        }
        twitterClient = [[TwitterClient alloc] initWithTarget:self action:@selector(followDidRequest:messages:)];
        [twitterClient friendship:user.screenName create:!following];
        followButton.enabled = false;
    }
}

- (void)setFriendship:(BOOL)exists
{
    following = exists;
    buttonState = (exists) ? FOLLOW_BUTTON_FOLLOWING : FOLLOW_BUTTON_FOLLOW;

    if (exists) {
        [followButton setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
    }
    else {
        [followButton setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    }
    [self setNeedsDisplay];
    [self setAnimation:followButton forKey:kFollowButtonAnim];
}

@end
