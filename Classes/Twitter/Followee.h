//
//  Followee.h
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface Followee : NSObject {
	uint32_t    userId;
    NSString*   name;
	NSString*   screenName;
    NSString*   profileImageUrl;
}

@property(nonatomic, assign) uint32_t  userId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* screenName;
@property(nonatomic, retain) NSString* profileImageUrl;

+ (void)insertDB:(User*)user;
+ (void)updateDB:(User*)user;
+ (void)deleteFromDB:(User*)user;

+ (Followee*)initWithDB:(sqlite3_stmt*)statement;

@end
