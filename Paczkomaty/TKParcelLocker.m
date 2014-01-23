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
@property (readwrite, assign, nonatomic) CLLocationCoordinate2D coordinate;
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

+ (TKParcelLocker *)lockerWithSQLStatement:(sqlite3_stmt *)statement{
    TKParcelLocker *locker = [[TKParcelLocker alloc] init];
    

    char *name              = (char *) sqlite3_column_text  (statement, 0);
    char *postalCode        = (char *) sqlite3_column_text  (statement, 1);
    char *province          = (char *) sqlite3_column_text  (statement, 2);
    char *street            = (char *) sqlite3_column_text  (statement, 3);
    char *buildingNumber    = (char *) sqlite3_column_text  (statement, 4);
    char *town              = (char *) sqlite3_column_text  (statement, 5);
    double longitude        =          sqlite3_column_double(statement, 6);
    double latitude         =          sqlite3_column_double(statement, 7);
    char *locationDesc      = (char *) sqlite3_column_text  (statement, 8);
    char *paymentPointDesc  = (char *) sqlite3_column_text  (statement, 9);
    NSInteger partnerId     =          sqlite3_column_int   (statement, 10);
    char *paymentType       = (char *) sqlite3_column_text  (statement, 11);
    char *operatingHours    = (char *) sqlite3_column_text  (statement, 12);
    char *status            = (char *) sqlite3_column_text  (statement, 13);
    BOOL paymentAvailable   = (BOOL)   sqlite3_column_int   (statement, 14);
    char *type              = (char *) sqlite3_column_text  (statement, 15);
    
    CLLocationCoordinate2D location;
    location.latitude = latitude;
    location.longitude = longitude;
    
    locker.name = [[NSString alloc] initWithUTF8String:name];
    locker.postalCode = [[NSString alloc] initWithUTF8String:postalCode];
    locker.province = [[NSString alloc] initWithUTF8String:province];
    locker.street = [[NSString alloc] initWithUTF8String:street];
    locker.buildingNumber = [[NSString alloc] initWithUTF8String:buildingNumber];
    locker.town = [[NSString alloc] initWithUTF8String:town];
    locker.coordinate = location;
    locker.locationDescription = [[NSString alloc] initWithUTF8String:locationDesc];
    locker.paymentPointDescription = [[NSString alloc] initWithUTF8String:paymentPointDesc];
    locker.parternId = partnerId;
    locker.paymentType = [[NSString alloc] initWithUTF8String:paymentType];
    locker.operatingHours = [[NSString alloc] initWithUTF8String:operatingHours];
    locker.status = [[NSString alloc] initWithUTF8String:status];
    locker.paymentAvailable = paymentAvailable;
    locker.type = [[NSString alloc] initWithUTF8String:type];
    
    return locker;
}

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
    locker.coordinate = coordinate;
    
    locker.locationDescription = [[element child:@"locationdescription"] text];
    locker.paymentPointDescription = [[element child:@"paymentpointdescr"] text];
    
    locker.parternId = [[element child:@"partnerid"] textAsInt];
    locker.paymentType = [[element child:@"paymenttype"] text];
    locker.operatingHours = [[element child:@"operatinghours"] text];
    locker.status = [[element child:@"status"] text];
    NSString *paymentavailable = [[element child:@"paymentavailable"] text];;
    locker.paymentAvailable = [paymentavailable isEqualToString:@"f"] ? YES :([paymentavailable isEqualToString:@"t"] ? NO : NO);
    locker.type = [[element child:@"type"] text];

    return locker;
}

+ (NSString *)sqlTableName{
    return @"lockers";
}

+ (NSString *)sqlTableModel{
    return @"lockers (name TEXT NOT NULL, postalCode TEXT NOT NULL, province TEXT, street TEXT, buildingNumber TEXT, town TEXT, longitude DOUBLE, latitude DOUBLE, locationDescription TEXT, paymentPointDescription TEXT, parterId INTEGER, paymentType TEXT, operatingHours TEXT, status TEXT, paymentAvailable INTEGER, type TEXT)";
}

+ (NSString *)sqlInsertFormat{
    return @"INSERT INTO lockers VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%f\", \"%f\", \"%@\", \"%@\", \"%d\", \"%@\", \"%@\", \"%@\", \"%d\", \"%@\")";
}

- (NSString *)sqlInsert{
    NSString *format = [TKParcelLocker sqlInsertFormat];
    
    NSString *escapedLocationDescription = [self.locationDescription stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    NSString *escapedPaymentPointDescription = [self.paymentPointDescription stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    return [NSString stringWithFormat:format,
            self.name ?: @"",
            self.postalCode ?: @"",
            self.province ?: @"",
            self.street ?: @"",
            self.buildingNumber ?: @"",
            self.town ?: @"",
            self.coordinate.longitude,
            self.coordinate.latitude,
            escapedLocationDescription ?: @"",
            escapedPaymentPointDescription ?: @"",
            self.parternId,
            self.paymentType ?: @"",
            self.operatingHours ?: @"",
            self.status ?: @"",
            self.paymentAvailable,
            self.type ?: @""];
}

#pragma mark - MKAnnotaion

- (NSString *)title{
    return [NSString stringWithFormat:@"%@", self.name];
}
- (NSString *)subtitle{
    return [NSString stringWithFormat:@"%@, %@ %@", self.town ?: @"", self.street ?: @"", self.buildingNumber ?: @""];
}

@end
