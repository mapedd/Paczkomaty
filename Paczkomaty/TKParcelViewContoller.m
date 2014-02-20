//
//  TKParcelViewContoller.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelViewContoller.h"
#import "TKLockerListViewController.h"
#import "PGSQLController.h"
#import "TKLockerHelper.h"
#import "TKParcelLocker.h"
#import "TKMapViewController.h"

@interface TKParcelViewContoller () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readwrite, strong, nonatomic) PGSQLController *sqlController;
@property (readwrite, strong, nonatomic) CLLocation *userLocation;
@end

@implementation TKParcelViewContoller

#pragma mark - NSObject

- (void)dealloc{
    [self.locationManager stopUpdatingLocation];
}

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    
    NSString *title = TKLocalizedStringWithToken(@"button-title.cancel");
    TKLockerListViewController *vc1 = [TKLockerListViewController new];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    vc1.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStyleBordered) target:self action:@selector(cancelSelection)];
    
    TKMapViewController *vc2 = [TKMapViewController new];
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    vc2.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStyleBordered) target:self action:@selector(cancelSelection)];
    
    [self setViewControllers:@[nc1,nc2]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    return self;
}

#pragma mark - Public

+ (TKParcelLocker *)lastSelectedParcelLocker{
    PGSQLController *sqlController = [[PGSQLController alloc] init];
    return [sqlController lastSelectedLocker];
}

+ (TKParcelLocker *)lockerWithName:(NSString *)lockerName{
    PGSQLController *sqlController = [[PGSQLController alloc] init];
    return [sqlController parcelWithName:lockerName];
}


#pragma mark - UIViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)cancelSelection{
    [self.parcelDelegate parcelControllerWantCancel:self];
}

- (void)didSelectLocker:(TKParcelLocker *)locker{
    locker.isSelected = YES;
    [self.sqlController setLockerAsSelected:locker];
    [self.parcelDelegate parcelController:self didSelectLocker:locker];
}

#pragma mark - Getters

- (PGSQLController *)sqlController{
    if (_sqlController == nil) {
        _sqlController = [[PGSQLController alloc] init];
    }
    return _sqlController;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
    if  (newLocation.horizontalAccuracy < 1000.0 && newLocation.horizontalAccuracy > 0.0f) {
        self.userLocation = newLocation;
        [self.locationManager stopUpdatingLocation];
    }
}

@end
