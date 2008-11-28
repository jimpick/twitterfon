//
//  LocationDistanceWindow.h
//  TwitterFon
//
//  Created by kaz on 11/28/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationDistanceWindowDelegate;

@interface LocationDistanceWindow : UIWindow <UIPickerViewDelegate, UIPickerViewDataSource> 
{
    UIView*         overlay;
    UIView*         container;
    UIPickerView*   picker;
    
    id<LocationDistanceWindowDelegate>  delegate;
}

- (id) initWithDelegate:(id)delegate selectedRow:(int)index;
- (void) show;

+ (NSString*)stringOfDistance:(int)index;
+ (int)distanceOf:(int)index;
+ (BOOL)useMetric;

@end

@protocol LocationDistanceWindowDelegate <NSObject>

- (void)locationDistanceWindow:(LocationDistanceWindow *)window didChangeDistance:(int)index;

@end