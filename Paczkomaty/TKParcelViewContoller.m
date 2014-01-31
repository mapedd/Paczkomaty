//
//  TKParcelViewContoller.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelViewContoller.h"
#import "TKViewController.h"
#import "TKMapViewController.h"

@interface TKParcelViewContoller () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readwrite, strong, nonatomic) CLLocation *userLocation;
@end

@implementation TKParcelViewContoller

- (void)dealloc{
    [self.locationManager stopUpdatingLocation];
}

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    
    
    TKViewController *vc1 = [TKViewController new];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    TKMapViewController *vc2 = [TKMapViewController new];
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    [self setViewControllers:@[nc1,nc2]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
    if (newLocation.horizontalAccuracy < 1000.0 && newLocation.horizontalAccuracy > 0.0f) {
        self.userLocation = newLocation;
        [self.locationManager stopUpdatingLocation];
    }
}

@end
