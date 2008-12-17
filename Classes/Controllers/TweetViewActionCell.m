//
//  UserViewActionCell.m
//  TwitterFon
//
//  Created by kaz on 12/3/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "TweetViewActionCell.h"
#import "TwitterFonAppDelegate.h"

@implementation TweetViewActionCell

@synthesize status;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        reply = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [reply setTitle:@"Reply" forState:UIControlStateNormal];
        [self.contentView addSubview:reply];
        [reply addTarget:self action:@selector(postTweet:) forControlEvents:UIControlEventTouchUpInside];
        
        dm = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [dm setTitle:@"Send a DM" forState:UIControlStateNormal];
        [self.contentView addSubview:dm];
        [dm addTarget:self action:@selector(postTweet:) forControlEvents:UIControlEventTouchUpInside];
        
        retweet = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [retweet setTitle:@"Retweet" forState:UIControlStateNormal];
        [self.contentView addSubview:retweet];
        [retweet addTarget:self action:@selector(postTweet:) forControlEvents:UIControlEventTouchUpInside];
        
       
    }
    return self;
}

- (void)postTweet:(id)sender
{
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    PostViewController* postView = appDelegate.postView;

    if (sender == reply) {
        [postView inReplyTo:status];
    }
    else if (sender == dm) {
        [postView editDirectMessage:status.user.screenName];
    }
    else if (sender == retweet) {
        [postView retweet:[NSString stringWithFormat:@"RT @%@: %@", status.user.screenName, status.text]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
    reply.frame     = CGRectMake(-1, 0, 94 , 44);
    dm.frame        = CGRectMake(102, 0, 96 , 44);
    retweet.frame   = CGRectMake(206 + 1, 0, 94 , 44);
}

- (void)dealloc {
    [super dealloc];
}


@end
