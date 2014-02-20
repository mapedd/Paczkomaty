//
//  TKLockerMockingFunctions.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 20/02/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKLockerMockingFunctions.h"


TKParcelLocker * lockerWithName(NSString *name, CLLocationCoordinate2D location){
    NSDictionary *dictionary = (@{
                                  @"name"                   : name,
                                  @"postcode"               : @"12-231",
                                  @"province"               : @"Mazowiewckie",
                                  @"street"                 : @"Bukowińska",
                                  @"buildingnumber"         : @"12/408",
                                  @"town"                   : @"Warszawa",
                                  @"longitude"              : @(location.longitude),
                                  @"latitude"               : @(location.latitude),
                                  @"locationdescription"    : @"Location Description",
                                  @"paymentpointdescr"      : @"Payment Point Description",
                                  @"partnerid"              : @13,
                                  @"paymenttype"            : @"Payment type",
                                  @"operatinghours"         : @"Paczkomat 24/7",
                                  @"status"                 : @"Operaing",
                                  @"paymentavailable"       : @"f",
                                  @"type"                   : @"type"
                                  });
    
    return [TKParcelLocker lockerWithNSDictionary:dictionary];
}