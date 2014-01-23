//
//  TKMapViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 08/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKMapViewController.h"
#import <MapKit/MapKit.h>
#import "TKParcelDetailViewController.h"
#import "TKParcelLocker.h"
#import "PGSQLController.h"

@interface TKMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *items;
@end

@implementation TKMapViewController

#pragma mark - NSObject

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    self.title = NSLocalizedString(@"Paczkomaty",nil);
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map",nil) image:[self tabBarImage] tag:1];
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    
    NSString *fileName ;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        fileName = @"arrow_io7";
    }
    else{
        fileName = @"arrow_io6";
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:fileName]
                                                                              style:(UIBarButtonItemStyleBordered)
                                                                             target:self
                                                                             action:@selector(showMe:)];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.items = [[PGSQLController sharedController] exportParcelsFromRegion:[self userMapRegion]];
//    self.items = [self.items subarrayWithRange:NSMakeRange(0, MIN(10, self.items.count))];
    for (TKParcelLocker *locker in self.items) {
        [self.mapView addAnnotation:locker];
    }
    
}

#pragma mark - Action

- (MKCoordinateRegion)userMapRegion{
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = location.latitude;
    mapRegion.center.longitude = location.longitude;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
    return mapRegion;
}

- (void)showMe:(id)sender{

    
    [self.mapView setRegion:[self userMapRegion]
                   animated: self.isViewLoaded];
    self.mapView.centerCoordinate = self.mapView.userLocation.coordinate;
}

#pragma mark - Setters

- (void)setItems:(NSArray *)items{
    if (_items != items) {
        _items = items;
    }
}

#pragma mark - Getters

- (UIImage *)tabBarImage{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"location_ios7"];
    }else{
        return [UIImage imageNamed:@"location_ios6"];
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    TKParcelLocker *locker = (TKParcelLocker *)view.annotation;
    TKParcelDetailViewController *detail = [[TKParcelDetailViewController alloc] init];
    detail.parcel = locker;
    [self.navigationController pushViewController:detail animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation{
	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[TKParcelLocker class]])
	{
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (annotationView == nil)
		{
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			annotationView.canShowCallout = YES;
			annotationView.animatesDrop = NO;
            
            UIButton *rightCallout = [UIButton buttonWithType:UIButtonTypeInfoLight];
            
            annotationView.rightCalloutAccessoryView = rightCallout;
		}
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self showMe:nil];
}

@end
