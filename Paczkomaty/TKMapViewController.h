//
//  TKMapViewController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 08/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface TKMapViewController : UIViewController
@property (strong, nonatomic) CLLocation *userLocation;
@end
