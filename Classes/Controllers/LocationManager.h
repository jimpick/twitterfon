//
//  LocationManager.h
//  TwitterFon
//
//  Created by kaz on 10/27/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager*  locationManager;
	id                  delegate;
}

- (id)initWithDelegate:(id)delegate;
- (void)getCurrentLocation;

@end
