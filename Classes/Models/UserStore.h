//
//  UserStore.h
//  TwitterFon
//
//  Created by kaz on 12/31/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserStore : NSObject {
}

+ (void)initDictionary;
+ (User*)getUser:(NSString*)screenName;
+ (User*)getUserWithId:(int)id;
+ (void)setUser:(User*)user;
@end
