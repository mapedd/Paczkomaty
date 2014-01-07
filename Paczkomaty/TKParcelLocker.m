//
//  TKParcelLocker.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelLocker.h"
#import <RXMLElement.h>

@interface TKParcelLocker ()

@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, strong, nonatomic) NSString *postalCode;
@property (readwrite, strong, nonatomic) NSString *province;
@property (readwrite, strong, nonatomic) NSString *street;
@property (readwrite, strong, nonatomic) NSString *buildingNumber;
@property (readwrite, strong, nonatomic) NSString *town;
@property (readwrite, assign, nonatomic) CLLocationCoordinate2D location;
@property (readwrite, assign, nonatomic) BOOL paymentAvailable;
@property (readwrite, strong, nonatomic) NSString *operatingHours;
@property (readwrite, strong, nonatomic) NSString *locationDescription;
@property (readwrite, strong, nonatomic) NSString *paymentPointDescription;
@property (readwrite, assign, nonatomic) long parternId;
@property (readwrite, strong, nonatomic) NSString *paymentType;
@property (readwrite, strong, nonatomic) NSString *type;
@property (readwrite, strong, nonatomic) NSString *status;

@end

@implementation TKParcelLocker
+ (TKParcelLocker *)lockerWithXMLElement:(RXMLElement *)element{
    
    TKParcelLocker *locker = [[TKParcelLocker alloc] init];
    
    locker.name = [[element child:@"name"] text];
    locker.postalCode =[[element child:@"postcode"] text];
    locker.province = [[element child:@"province"] text];
    locker.street = [[element child:@"street"] text];
    locker.buildingNumber = [[element child:@"buildingnumber"] text];
    locker.town = [[element child:@"town"] text];
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [[element child:@"longitude"] textAsDouble];
    coordinate.latitude = [[element child:@"latitude"] textAsDouble];
    locker.location = coordinate;
    
    locker.locationDescription = [[element child:@"locationdescription"] text];
    locker.paymentPointDescription = [[element child:@"paymentpointdescr"] text];
    
    locker.parternId = [[element child:@"partnerid"] textAsInt];
    locker.paymentType = [[element child:@"paymenttype"] text];
    locker.operatingHours = [[element child:@"operatinghours"] text];
    locker.status = [[element child:@"operatinghours"] text];
    NSString *paymentavailable = [[element child:@"paymentavailable"] text];;
    locker.paymentAvailable = [paymentavailable isEqualToString:@"f"] ? YES :([paymentavailable isEqualToString:@"t"] ? NO : NO);
    locker.type = [[element child:@"type"] text];

    return locker;
}
@end
