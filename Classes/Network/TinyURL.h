//
//  TinyURL.h
//  TwitterFon
//
//  Created by kaz on 7/26/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFConnection.h"

@interface TinyURL : TFConnection {
    NSString*   givenURL;
}

@property (nonatomic, copy) NSString* givenURL;

- (void)decode:(NSString*)tinyURL;
- (void)encode:(NSString*)URL;

+ (BOOL)needToDecode:(NSString*)anURL;
@end
