//
//  ChatBubbleView.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ChatBubbleView.h"
#import "TwitterFonAppDelegate.h"

static UIImage* sGreenBubble = nil;
static UIImage* sGrayBubble = nil;

@interface ChatBubbleView(Private)
+ (UIImage*)greenBubble;
+ (UIImage*)grayBubble;
@end

@implementation ChatBubbleView

@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setMessage:(DirectMessage*)aMessage type:(BubbleType)aType
{
    message = aMessage;
    type = aType;
    [self setNeedsDisplay];    
}

#define IMAGE_SIZE 32
#define IMAGE_H_PADDING 8

- (void)drawRect:(CGRect)rect 
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    if (message.cellType == TWEET_CELL_TYPE_NORMAL) {
        
        CGContextSetShadowWithColor(c, CGSizeMake(0, -1), 3, [[UIColor darkGrayColor] CGColor]);        
        
        // Draw message with chat bubble and profile icon
        //
        CGRect imageRect = CGRectMake(0, 0, IMAGE_SIZE, IMAGE_SIZE);
        imageRect.origin.y = rect.size.height - IMAGE_SIZE - 1 - 4;
        if (type == BUBBLE_TYPE_GRAY) {
            imageRect.origin.x = IMAGE_H_PADDING;
        }
        else {
            imageRect.origin.x = 320 - IMAGE_H_PADDING - IMAGE_SIZE;
        }
        [image drawInRect:imageRect];
        
        CGContextSetShadowWithColor(c, CGSizeMake(0, 0), 0, [[UIColor whiteColor] CGColor]);        
        
        // Draw chat bubble
        UIImage *bubble;
        CGRect bubbleRect = message.textRect;
        
        int width = bubbleRect.size.width + 30;
        width = (width / 10) * 10 + ((width % 10) ? 10 : 0);
        bubbleRect.size.width = width;
        bubbleRect.size.height += 15;
        bubbleRect.origin.y = 4;
        
        if (type == BUBBLE_TYPE_GRAY) {
            bubble = [ChatBubbleView grayBubble];
            bubbleRect.origin.x = IMAGE_SIZE + IMAGE_H_PADDING;
        }
        else {
            bubble = [ChatBubbleView greenBubble];
            bubbleRect.origin.x = 320 - bubbleRect.size.width - IMAGE_SIZE - IMAGE_H_PADDING;
        }
        [bubble drawInRect:bubbleRect];
        
        [[UIColor blackColor] set];
        bubbleRect.origin.y += 6;
        bubbleRect.size.width = message.textRect.size.width;
        if (type == BUBBLE_TYPE_GRAY) {
            bubbleRect.origin.x += 20;
        }
        else {
            bubbleRect.origin.x += 10;
        }
        [message.text drawInRect:bubbleRect withFont:[UIFont systemFontOfSize:14]];
    }
    else {
        // Draw timestamp only
        //
        UIColor *timestampColor = [UIColor darkGrayColor];
        [timestampColor set];
        
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.createdAt];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        [formattedDateString drawInRect:CGRectMake(0, 6, 320, 16) withFont:[UIFont boldSystemFontOfSize:12]
                          lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    }
}


- (void)dealloc {
    [image release];
    [super dealloc];
}

+ (UIImage*)greenBubble
{
    if (sGreenBubble == nil) {
        UIImage *i = [UIImage imageNamed:@"Balloon_1.png"];
        sGreenBubble = [[i stretchableImageWithLeftCapWidth:15 topCapHeight:13] retain];
    }
    return sGreenBubble;
}

+ (UIImage*)grayBubble
{
    if (sGrayBubble == nil) {
        UIImage *i = [UIImage imageNamed:@"Balloon_2.png"];
        sGrayBubble = [[i stretchableImageWithLeftCapWidth:21 topCapHeight:13] retain];
    }
    return sGrayBubble;
}

@end
