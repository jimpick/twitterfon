//
//  PostView.h
//  TwitterFon
//
//  Created by kaz on 10/25/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface PostView : UIView {
    IBOutlet UITextView*        text;
    IBOutlet UILabel*           to;
    IBOutlet UITextField*       recipient;
    IBOutlet UIToolbar*         toolbar;
    IBOutlet UIBarButtonItem*   sendButton;
    IBOutlet UILabel*           charCount;
    
    NSString*                   inReplyToMessage;
    sqlite_int64                inReplyToMessageId;
    
    NSString*                   undoBuffer;
    sqlite_int64                savedId;
    
    BOOL                        isDirectMessage;
}

@property(nonatomic, assign) sqlite_int64 inReplyToMessageId;

- (IBAction) clear:(id)sender;

- (void)editDirectMessage:(NSString*)recipient;
- (void)editReply:(Message*)message;
- (void)editPost;
- (void)editRetweet;
- (void)setCharCount;
- (void)saveTweet;

@end
