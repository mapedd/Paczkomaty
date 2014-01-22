//
//  TKParcelView.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class TKParcelLocker;
@interface TKParcelView : UIView
@property (strong, nonatomic) TKParcelLocker *parcel;

@property (readonly, strong, nonatomic) UILabel *nameLabel;
@property (readonly, strong, nonatomic) UILabel *addressLabel;
@property (readonly, strong, nonatomic) UILabel *localisationLabel;
@property (readonly, strong, nonatomic) UILabel *hoursLabel;
@property (readonly, strong, nonatomic) UILabel *paymentLabel;
@end
