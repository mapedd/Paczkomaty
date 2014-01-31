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
#import "TKParcelViewContoller.h"
#import "TKParcelLocker.h"
#import "PGSQLController.h"

@interface TKMapViewController () <MKMapViewDelegate>{
    BOOL _userLocationWasShown;
}
@property (strong, nonatomic) MKMapView *mapView;

@property (strong, nonatomic) NSSet *visibleAnnotationsBeforeUpdate;

@property (strong, nonatomic) dispatch_queue_t queue;


@property (strong, nonatomic) NSArray *sortDescriptors;
@end

@implementation TKMapViewController

#pragma mark - NSObject

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    self.title = NSLocalizedString(@"Paczkomaty",nil);
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Map",nil) image:[self tabBarImage] tag:1];
    self.queue = dispatch_queue_create("com.paczkomaty.databaseFetchQueue", NULL);
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hash" ascending:YES]];
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
    
    
    [self loadNavBarButton];
    
    [self attachToMapViewGestureRecognizers];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    TKParcelViewContoller *vc = (TKParcelViewContoller *)self.parentViewController;
    if ([vc isKindOfClass:[TKParcelViewContoller class]]) {
        [self.mapView setRegion:[self mapRegionWithLocation:vc.userLocation]
                       animated:animated];
    }
    [self mapView:self.mapView regionWillChangeAnimated:NO];
    [self mapView:self.mapView regionDidChangeAnimated:NO];
}

#pragma mark - Action

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch{
    //    NSLog(@"map view pinch");
}

- (void)handlePan:(UIPanGestureRecognizer *)pan{
    //    NSLog(@"map view pan");
}

- (void)showMe:(id)sender{
    MKUserLocation *userLocation = self.mapView.userLocation;
    [self.mapView setRegion:[self mapRegionWithLocation:userLocation.location]
                   animated:YES];

}

#pragma mark - Getters

- (UIImage *)tabBarImage{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"location_ios7"];
    }else{
        return [UIImage imageNamed:@"location_ios6"];
    }
}

#pragma mark - Private

- (MKCoordinateRegion)mapRegionWithLocation:(CLLocation *)locationObject{
    CLLocationCoordinate2D location = locationObject.coordinate;
    NSLog(@"is valid location = %d", CLLocationCoordinate2DIsValid(location));
    MKCoordinateRegion mapRegion;
    mapRegion.center.latitude = location.latitude;
    mapRegion.center.longitude = location.longitude;
    mapRegion.span.latitudeDelta = 0.05;
    mapRegion.span.longitudeDelta = 0.05;
    
    return mapRegion;
}

- (void)attachToMapViewGestureRecognizers{
    NSArray *mapViewGestureRecognizers;
    
    for (UIView *mapViewSubview in self.mapView.subviews) {
        if (mapViewSubview.gestureRecognizers.count == 0) {
            continue;
        }
        
        mapViewGestureRecognizers = mapViewSubview.gestureRecognizers;
        break;
    }
    
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    UIPanGestureRecognizer *panGestureRecognizer;
    
    for (id gestureRecognizer in mapViewGestureRecognizers) {
        if (![NSStringFromClass([gestureRecognizer class]) hasPrefix:@"UI"]) {
            continue;
        }
        if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
            pinchGestureRecognizer = gestureRecognizer;
        }
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            panGestureRecognizer = gestureRecognizer;
        }
    }
    
    [pinchGestureRecognizer addTarget:self action:@selector(handlePinch:)];
    [panGestureRecognizer addTarget:self action:@selector(handlePan:)];
}

- (void)loadNavBarButton{
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

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
    self.visibleAnnotationsBeforeUpdate = [NSSet setWithArray:[mapView annotations]];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self updateAnnotationsInRegion:[mapView region]];
}

- (void)updateAnnotationsInRegion:(MKCoordinateRegion)region{
    __unsafe_unretained typeof(self) bself = self;
    dispatch_async(self.queue, ^{
        @autoreleasepool {
            NSArray *visibleAnnotations = [[PGSQLController sharedController] exportParcelsFromRegion:region];
            NSMutableSet *annotationsThatShouldBeVisible = [[NSSet setWithArray:visibleAnnotations] mutableCopy];
            
            NSSet *annotationsThatShouldBeVisibleCopy = [annotationsThatShouldBeVisible copy];
            [annotationsThatShouldBeVisible minusSet:bself.visibleAnnotationsBeforeUpdate];
            NSArray *annotationToAdd = [annotationsThatShouldBeVisible sortedArrayUsingDescriptors:bself.sortDescriptors];
            
            NSMutableSet *toRemove = [bself.visibleAnnotationsBeforeUpdate mutableCopy];
            [toRemove minusSet:annotationsThatShouldBeVisibleCopy];
            NSArray *annotationsToRemove = [toRemove sortedArrayUsingDescriptors:bself.sortDescriptors];
            bself.visibleAnnotationsBeforeUpdate = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [bself.mapView removeAnnotations:annotationsToRemove];
                [bself.mapView addAnnotations:annotationToAdd];
            });
        }
    });
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    TKParcelLocker *locker = (TKParcelLocker *)view.annotation;
    TKParcelDetailViewController *detail = [[TKParcelDetailViewController alloc] init];
    detail.parcel = locker;
    [self.navigationController pushViewController:detail animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *annotationIdentifier = @"Pin";
	MKPinAnnotationView *annotationView = nil;
	if ([annotation isKindOfClass:[TKParcelLocker class]])
	{
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		if (annotationView == nil)
		{
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
			annotationView.canShowCallout = YES;
			annotationView.animatesDrop = NO;
            
            UIButton *rightCallout = [UIButton buttonWithType:UIButtonTypeInfoLight];
            
            annotationView.rightCalloutAccessoryView = rightCallout;
		}
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    
    if (userLocation.location.horizontalAccuracy > 1000) {
        return;
    }
    
    
    if (_userLocationWasShown) {
        return;
    }
    _userLocationWasShown = YES;
    
    [self showMe:nil];
}

@end
