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
        locationManager.distanceFilter = 100.0;
    }
    locationManager.startUpdatingLocation;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];

    if (abs(howRecent) < 5.0) {
        [manager stopUpdatingLocation];
        
        locationManager.stopUpdatingLocation;
        [delegate locationManagerDidReceiveLocation:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        [locationManager autorelease];
        locationManager = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}   

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    locationManager.stopUpdatingLocation;
    
    if (!([error code] == kCLErrorDenied && [[error domain] compare:kCLErrorDomain] == NSOrderedSame)) {
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles: nil];
        [alert show];	
        [alert release];
    }

    
    [delegate locationManagerDidFail];
    [locationManager autorelease];
    locationManager = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
