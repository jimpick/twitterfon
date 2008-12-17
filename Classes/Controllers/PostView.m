//
//  PostView.m
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "PostView.h"
#import "QuartzUtils.h"

#define kDeleteAnimationKey @"deleteAnimation"
#define kUndoAnimationKey   @"undoAnimation"

#define DELETE_BUTTON_INDEX 0

@implementation PostView

@synthesize inReplyToStatusId;

- (void)awakeFromNib
{
    recipient.font = [UIFont systemFontOfSize:16];
    charCount.font = [UIFont boldSystemFontOfSize:16];
    
    text.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"tweet"];
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:@"inReplyToStatusId"];
    isDirectMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDirectMessage"];
    inReplyToStatusId = [number longLongValue];
    if (inReplyToStatusId) {
        to.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"to"];
        recipient.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"recipient"];
    }
}

- (void)editDirectMessage:(NSString*)aRecipient
{
    isDirectMessage = true;
    if (aRecipient) {
        recipient.enabled = false;
        recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        recipient.text = aRecipient;
    }
    else {
        recipient.enabled = true;
        recipient.text = @"";
        recipient.textColor = [UIColor blackColor];
    }
    inReplyToStatusId = 0;
    to.text = @"To:";
}

- (void)editReply:(Status*)status
{
    isDirectMessage = false;
    if (inReplyToStatus) {
        [inReplyToStatus release];
    }

    inReplyToStatus   = [status.text copy];
    inReplyToStatusId = status.statusId;
    
    to.text = @"In-Reply-To:";
    recipient.text = inReplyToStatus;
    recipient.enabled = false;
    recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
}

- (void)editPost
{
    isDirectMessage = false;
}

- (void)editRetweet
{
    isDirectMessage = false;
    inReplyToStatusId = 0;
}

- (void)createTransform:(BOOL)isDelete
{
    if (isDelete) {
        CGAffineTransform transform = CGAffineTransformMakeScale(0.01, 0.01);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-80.0, 140.0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0.5);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        self.transform = transform;
    }
    else {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(0, 0);
        CGAffineTransform transform3 = CGAffineTransformMakeRotation (0);
        
        transform = CGAffineTransformConcat(transform,transform2);
        transform = CGAffineTransformConcat(transform,transform3);
        self.transform = transform;
    }
}

- (IBAction) clear:(id) sender
{
    [UIView beginAnimations:kDeleteAnimationKey context:self]; 

    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    item.enabled = false;
    
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self createTransform:true];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (IBAction) undo:(id) sender
{
    text.text = undoBuffer;
    inReplyToStatusId = savedId;
    [undoBuffer release];
    undoBuffer = nil;
    [self createTransform:true];
    [self setNeedsDisplay];
    
    UIBarButtonItem *item = (UIBarButtonItem*)sender;
    item.enabled = false;
    
    [UIView beginAnimations:kUndoAnimationKey context:self]; 
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [self createTransform:false];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];
    
}

- (void)replaceButton:(UIBarButtonItem*)item index:(int)index
{
    NSMutableArray *items = [toolbar.items mutableCopy];
    [items replaceObjectAtIndex:index withObject:item];
    [toolbar setItems:items animated:false];
    [items release];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:kDeleteAnimationKey]) {
        [self createTransform:false];
        
        undoBuffer = [text.text retain];
        savedId = inReplyToStatusId;
        inReplyToStatusId = 0;
        text.text = @"";
        charCount.textColor = [UIColor whiteColor];
        sendButton.enabled = false;
        [self setNeedsDisplay];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Undo" style:UIBarButtonItemStyleBordered target:self action:@selector(undo:)];
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
    else if ([animationID isEqualToString:kUndoAnimationKey]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
}

- (void)setCharCount
{
    int length = [text.text length];
    
    if (undoBuffer && length > 0) {
        [undoBuffer release];
        undoBuffer = nil;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(clear:)];
        item.style = UIBarButtonItemStyleBordered;
        [self replaceButton:item index:DELETE_BUTTON_INDEX];
    }
    
    length = 140 - length;
    if (length == 140) {
        sendButton.enabled = false;
    }
    else if (length < 0) {
        sendButton.enabled = false;
        charCount.textColor = [UIColor redColor];
    }
    else {
        sendButton.enabled = true;
        charCount.textColor = [UIColor whiteColor];
    }
    
    if (isDirectMessage && [recipient.text length] == 0) {
        sendButton.enabled = false;
    }
    
    charCount.text = [NSString stringWithFormat:@"%d", length];
}

- (void)saveTweet
{
    [[NSUserDefaults standardUserDefaults] setObject:text.text forKey:@"tweet"];
    [[NSUserDefaults standardUserDefaults] setObject:to.text forKey:@"to"];
    [[NSUserDefaults standardUserDefaults] setObject:recipient.text forKey:@"recipient"];
    [[NSUserDefaults standardUserDefaults] setBool:isDirectMessage forKey:@"isDirectMessage"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithLongLong:inReplyToStatusId] forKey:@"inReplyToStatusId"];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (isDirectMessage) {
        to.hidden = false;
        to.frame = CGRectMake(9, 0, 42, 43);
        
        recipient.hidden = false;
        recipient.frame = CGRectMake(40, 0, 270, 44);
        text.frame = CGRectMake(5, 44, 310, 112);
    }
    else if (inReplyToStatusId) {
        to.hidden = false;
        to.frame = CGRectMake(9, 0, 100, 43);
        
        recipient.frame = CGRectMake(110, 0, 200, 44);
        recipient.hidden = false;
        recipient.enabled = false;
        recipient.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        text.frame = CGRectMake(5, 44, 310, 112);
    }
    else {
        to.hidden = true;
        recipient.hidden = true;
        text.frame = CGRectMake(5, 5, 310, 156);
    }

}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (isDirectMessage || inReplyToStatusId) {
        CGContextSetLineWidth(context, 1);
        CGContextSetAllowsAntialiasing(context, false);
        CGContextSetRGBStrokeColor(context, 0.666, 0.666, 0.666, 1.0);
        CGPoint points[2] = {
            {0, 44}, {320, 44}
        };
        CGContextStrokeLineSegments(context, points, 2);
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
