//
//  TKParcelViewContoller.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TKParcelViewContoller : UITabBarController
@property (readonly, strong, nonatomic) CLLocation *userLocation;
@end
