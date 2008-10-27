//
//  LocationManager.m
//  TwitterFon
//
//  Created by kaz on 10/27/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "LocationManager.h"

@interface NSObject (LocationManagerDelegate)
- (void)locationManagerDidReceiveLocation:(float)latitude longitude:(float)longitude;
- (void)locationManagerDidFail;
@end


@implementation LocationManager

- (id)initWithDelegate:(id)aDelegate
{
    [super init];
    delegate = aDelegate;
    return self;
}

- (void)dealloc
{
    [locationManager release];
    [super dealloc];
}

- (void)getCurrentLocation
{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
    }
    locationManager.startUpdatingLocation;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    locationManager.stopUpdatingLocation;
    [delegate locationManagerDidReceiveLocation:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
}   

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [delegate locationManagerDidFail];
}

@end
