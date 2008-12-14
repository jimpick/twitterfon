//
//  FriendCell.m
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "FolloweeCell.h"
#import "TwitterFonAppDelegate.h"

@implementation FolloweeCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // name label
        screenName = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        screenName.backgroundColor = [UIColor whiteColor];
        screenName.textColor = [UIColor blackColor];
        screenName.highlightedTextColor = [UIColor whiteColor];
        screenName.font = [UIFont boldSystemFontOfSize:20];
        screenName.textAlignment = UITextAlignmentLeft;
        screenName.frame = CGRectMake(LEFT, 4, CELL_WIDTH, 24);
        [self.contentView addSubview:screenName];
        
        // screenName label
        name = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        name.backgroundColor = [UIColor whiteColor];
        name.textColor = [UIColor blackColor];
        name.highlightedTextColor = [UIColor whiteColor];
        name.font = [UIFont systemFontOfSize:14];
        name.frame = CGRectMake(LEFT, 30, CELL_WIDTH, 16);
        [self.contentView addSubview:name];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setFollowee:(Followee*)followee
{
    screenName.text = followee.screenName;
    name.text = followee.name;
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    self.image = [appDelegate.imageStore getImage:followee.profileImageUrl delegate:self];
}

- (void)setUser:(User*)user
{
    screenName.text = user.screenName;
    name.text = user.name;
    TwitterFonAppDelegate *appDelegate = (TwitterFonAppDelegate*)[UIApplication sharedApplication].delegate;
    self.image = [appDelegate.imageStore getImage:user.profileImageUrl delegate:self];
}

- (void)profileImageDidGetNewImage:(UIImage*)image
{
    [self setNeedsDisplay];
}

@end
