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
@synthesize hasDetail;
@synthesize height;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    UIImage *back = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(back.CGImage);
    lockIcon = [[UIImage imageNamed:@"lock.png"] retain];

    url = [UIButton buttonWithType:UIButtonTypeCustom];
    url.font = [UIFont boldSystemFontOfSize:14];  	
    [url setTitleColor:[UIColor colorWithRed:0.208 green:0.310 blue:0.518 alpha:1.0] forState:UIControlStateNormal];
    [url setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [url setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    url.lineBreakMode = UILineBreakModeTailTruncation;
    url.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    url.titleShadowOffset = CGSizeMake(0, 1);
    [self addSubview:url];
    
    protected = false;
    
    return self;
}

-(void)dealloc
{
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
    
    float w = profileImage.size.width;
    float h = profileImage.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
   
    CGPathMoveToPoint  (path, nil, 10+w, 20+h/2);
    CGPathAddArcToPoint(path, nil, 10+w, 20+h, 10+w/2, 20+h,    8);
    CGPathAddArcToPoint(path, nil, 10,   20+h, 10,     20+ h/2, 8);
    CGPathAddArcToPoint(path, nil, 10,   20,   10+w/2, 20,      8);
    CGPathAddArcToPoint(path, nil, 10+w, 20,   10+w,   20+h/2,  8);
    CGPathCloseSubpath(path);

    // Fill rect with drop shadow
    CGContextAddPath(context, path);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 12, [[UIColor darkGrayColor] CGColor]);
    // Drawing with a white stroke color
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    if (profileImage) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    }
    else {
        CGContextSetRGBFillColor(context, 0.7, 0.7, 0.7, 1.0);
    }
    CGContextFillPath(context);

    // Draw path with 2px pen
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBStrokeColor(context, 0.2, 0.2, 0.2, 1.0);
    CGContextSetShadowWithColor(context, CGSizeZero, 0, [[UIColor whiteColor] CGColor]);
    CGContextDrawPath(context, kCGPathStroke);
    
    if (profileImage) {
        CGContextAddPath(context, path);
        CGContextSaveGState(context);
        CGContextClip(context);
        [profileImage drawAtPoint:CGPointMake(10.0, 20.0)];
        CGContextRestoreGState(context);
    }
    CGPathRelease(path);
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
    
    if (protected) {
        [kMessageUserProtected drawInRect:CGRectMake(93, 16, 189, 44) withFont:[UIFont boldSystemFontOfSize:16]];
        [kMessageDetail drawInRect:CGRectMake(93, 59, 217, 36) withFont:[UIFont systemFontOfSize:14]];
    }
    else {
        CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
        
        if (hasDetail) {
            [user.name drawInRect:CGRectMake(93, 20, 189, 24) withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation];
            [user.location drawInRect:CGRectMake(93, 50, 217, 18) withFont:[UIFont systemFontOfSize:14]];
            url.frame = CGRectMake(93, 75, 217, 18);
        }
        else {
            [user.name drawInRect:CGRectMake(93, 20, 189, 44) withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation];
            [user.location drawInRect:CGRectMake(93, 59, 217, 18) withFont:[UIFont systemFontOfSize:14]];
            url.frame = CGRectMake(93, 77, 217, 18);
        }

        if (!hasDetail) {
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
        }
        
        if (user.protected) {
            [lockIcon drawAtPoint:CGPointMake(298, 22)];
        }
    }
    if (hasDetail) {
        [[UIColor blackColor] set];
        [user.description drawInRect:CGRectMake(20, 105, 280, 110) withFont:[UIFont systemFontOfSize:14] lineBreakMode:UILineBreakModeTailTruncation];
    }
}

-(void)setUser:(User*)aUser delegate:(id)delegate
{
    user = aUser;
    
    if ([user.url length]) {
        [url setTitle:user.url forState:UIControlStateNormal];
        [url setTitle:user.url forState:UIControlStateHighlighted];
        [url addTarget:delegate action:@selector(didTouchURL:) forControlEvents:UIControlEventTouchUpInside];   
    }
    else {
        url.enabled = false;
    }

    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14];
    label.text = user.description;
    label.lineBreakMode = UILineBreakModeTailTruncation;
    CGRect r = [label textRectForBounds:CGRectMake(20, 105, 280, 110) limitedToNumberOfLines:10];
    [label release];
    height = r.size.height + 115;

    [self setNeedsDisplay];
}

@end
