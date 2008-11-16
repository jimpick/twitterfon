//
//  UserCell.m
//  TwitterFon
//
//  Created by kaz on 8/20/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)awakeFromNib
{  	  	 
    name.font               = [UIFont boldSystemFontOfSize:18];  	  	 
    location.font           = [UIFont systemFontOfSize:14];  	  	 
    url.font                = [UIFont boldSystemFontOfSize:14];  	  	 
    url.lineBreakMode       = UILineBreakModeTailTruncation;  	  	 
    url.titleShadowOffset   = CGSizeMake(0, 1);
    numFollowers.font       = [UIFont systemFontOfSize:13];  	  	 
    numFollowers.textColor  = [UIColor darkGrayColor];
    
    UIImage *img = [UIImage imageNamed:@"usercell_background.png"];
    background = CGImageRetain(img.CGImage);
} 

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
  	CGContextDrawImage(context, rect, background);
    
    if (self.image) {
        // Drawing with a white stroke color
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetLineWidth(context, 2.0);
        
        // Add Rect to the current path, then stroke it
        CGContextAddRect(context, CGRectMake(10.0, 20.0, 73.0, 73.0));
        CGContextStrokePath(context);    
        CGContextAddRect(context, CGRectMake(10.0, 20.0, 73.0, 73.0));
        CGContextFillPath(context);  
    }    
    [super drawRect:rect];
}

-(void)clear
{
    name.text = @"";
    location.text = @"";
    [url setTitle:@"" forState:UIControlStateNormal];
    [url setTitle:@"" forState:UIControlStateHighlighted];
    numFollowers.hidden = true;
    self.image = nil;
    protected.hidden = true;
}

-(void)setErrorMessage:(NSString*)message detail:(NSString*)detail
{
    name.frame = CGRectMake(93, 16, 189, 44);
    name.numberOfLines = 2;
    name.font = [UIFont boldSystemFontOfSize:16];
    name.text = message;
    location.frame = CGRectMake(93, 59, 217, 36);
    location.text = detail;
    location.numberOfLines = 3;
    [self.contentView setNeedsDisplay];
}

-(void)update:(Message*)message delegate:(id)delegate
{
    name.frame = CGRectMake(93, 20, 189, 22);
    location.frame = CGRectMake(93, 59, 217, 18);
    
    name.text               = message.user.name;
    location.text           = message.user.location;
    [url setTitle:message.user.url forState:UIControlStateNormal];
    [url setTitle:message.user.url forState:UIControlStateHighlighted];

    numFollowers.hidden = (message.user.followersCount == 0) ? true : false;

    if (message.user.followersCount <= 1) {
        numFollowers.text   = [NSString stringWithFormat:@"%d follower", message.user.followersCount];
    }
    else {
        numFollowers.text   = [NSString stringWithFormat:@"%d followers", message.user.followersCount];
    }
    [url addTarget:delegate action:@selector(didTouchURL:) forControlEvents:UIControlEventTouchUpInside];   
    protected.hidden = (message.user.protected) ? false : true;

/*    
	description.font        = [UIFont systemFontOfSize:13];
    description.text        = message.user.description;
    description.numberOfLines = 5;
    description.hidden = true;
    CGRect bounds = CGRectMake(93, 93 - 4, 300, 193 - 4);
    description.frame = [description textRectForBounds:bounds limitedToNumberOfLines:5];
    return description.frame.size.height + 93 + 2;
 */
 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor colorWithRed:0.939 green:0.939 blue:0.939 alpha:1.0];
}

- (void)dealloc {
    CGImageRelease(background);
    [super dealloc];
}


@end
