//
//  TKParcelLocker+Helpers.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 31/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelLocker+Helpers.h"

@implementation TKParcelLocker (Helpers)
- (void)assignDistanceFromLocation:(CLLocation *)location{
    CLLocation *thisLockerLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    self.curentDistanceFromUser = [thisLockerLocation distanceFromLocation:location] / 1000.0f;
}
@end
