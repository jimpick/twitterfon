//
//  TweetCellView.h
//  TwitterFon
//
//  Created by kaz on 11/2/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface TweetCellView : UIView {
    Status*    status;
}

@property(nonatomic, retain) Status* status;

@end
