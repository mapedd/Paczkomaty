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

#define LIST_VIEW_CONTROLLER_INDEX 0
#define MAP_VIEW_CONTROLLER_INDEX 1

@interface TKParcelViewContoller () <CLLocationManagerDelegate, UITabBarControllerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (readwrite, strong, nonatomic) PGSQLController *sqlController;
@property (readwrite, strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) TKMapViewController *mapViewController;
@end

@implementation TKParcelViewContoller

#pragma mark - NSObject

- (void)dealloc{
    [self.locationManager stopUpdatingLocation];
}

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    
    self.delegate = self;
    
    NSString *title = TKLocalizedStringWithToken(@"button-title.cancel");
    TKLockerListViewController *vc1 = [TKLockerListViewController new];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    vc1.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStyleBordered) target:self action:@selector(cancelSelection)];
    
    self.mapViewController = [TKMapViewController new];
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];
    self.mapViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:(UIBarButtonItemStyleBordered) target:self action:@selector(cancelSelection)];
    
    [self setViewControllers:@[nc1,nc2]];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
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
    self.userLocation = newLocation;
    if  (newLocation.horizontalAccuracy < MIN_HORIZONTAL_ACCURACY && newLocation.horizontalAccuracy > 0.0f) {
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([tabBarController.viewControllers indexOfObject:viewController] == MAP_VIEW_CONTROLLER_INDEX) {
        self.mapViewController.userLocation = self.userLocation;
    }
    return YES;
}

@end
