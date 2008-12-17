//
//  ChatBubbleView.m
//  TwitterFon
//
//  Created by kaz on 12/17/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "ChatBubbleView.h"
static UIImage* sGreenBubble = nil;
static UIImage* sGrayBubble = nil;

@interface ChatBubbleView(Private)
+ (UIImage*)greenBubble;
+ (UIImage*)grayBubble;
@end

@implementation ChatBubbleView

@synthesize type;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    UIImage *background;
    if (type == BUBBLE_TYPE_GRAY) {
        background = [ChatBubbleView grayBubble];
    }
    else {
        background = [ChatBubbleView greenBubble];
    }    
    [background drawInRect:rect];
}


- (void)dealloc {
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
