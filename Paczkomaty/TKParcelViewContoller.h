//
//  TKParcelViewContoller.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class TKParcelLocker, PGSQLController;

@protocol TKParcelViewContollerDelegate;

@interface TKParcelViewContoller : UITabBarController
@property (readonly, strong, nonatomic) CLLocation *userLocation;
@property (weak, nonatomic) id<TKParcelViewContollerDelegate> parcelDelegate;
@property (readonly, strong, nonatomic) PGSQLController *sqlController;
- (void)didSelectLocker:(TKParcelLocker *)locker;
@end


@protocol TKParcelViewContollerDelegate <NSObject>
@required
- (void)parcelController:(TKParcelViewContoller *)parcelViewController didSelectLocker:(TKParcelLocker *)locker;
@required
- (void)parcelControllerWantCancel:(TKParcelViewContoller *)parcelViewController;

@end