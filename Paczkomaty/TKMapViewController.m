//
//  TKMapViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 08/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKMapViewController.h"
#import <MapKit/MapKit.h>
#import "TKParcelLocker.h"
#import "PGSQLController.h"

@interface TKMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) PGSQLController *controller;
@end

@implementation TKMapViewController

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    self.title = NSLocalizedString(@"Map",nil);
    self.controller = [[PGSQLController alloc] init];
    self.items = [self.controller exportParcelsFromDataBase];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_io7"] style:(UIBarButtonItemStyleBordered) target:self action:@selector(showMe:)];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (TKParcelLocker *locker in self.items) {
        [self.mapView addAnnotation:locker];
    }

}

- (void)showMe:(id)sender{
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = location.latitude;
    mapRegion.center.longitude = location.longitude;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
    [self.mapView setRegion:mapRegion animated: YES];
    self.mapView.centerCoordinate = location;
}

- (void)setItems:(NSArray *)items{
    if (_items != items) {
        _items = items;
    }
}

#pragma mark - MKMapViewDelegate

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
		}
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self showMe:nil];
}

@end
