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
@property (readwrite, assign, nonatomic) TKLockerPaymentType paymentType;
@property (readwrite, strong, nonatomic) NSString *type;
@property (readwrite, strong, nonatomic) NSString *status;

@end

@implementation TKParcelLocker

- (void)dealloc{
    
}

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
    NSInteger paymentType   =          sqlite3_column_int   (statement, 11);
    char *operatingHours    = (char *) sqlite3_column_text  (statement, 12);
    char *status            = (char *) sqlite3_column_text  (statement, 13);
    BOOL paymentAvailable   = (BOOL)   sqlite3_column_int   (statement, 14);
    char *type              = (char *) sqlite3_column_text  (statement, 15);
    BOOL isSelected         = (BOOL)   sqlite3_column_int   (statement, 16);
    
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
    locker.paymentType = paymentType;
    locker.operatingHours = [[NSString alloc] initWithUTF8String:operatingHours];
    locker.status = [[NSString alloc] initWithUTF8String:status];
    locker.paymentAvailable = paymentAvailable;
    locker.type = [[NSString alloc] initWithUTF8String:type];
    locker.isSelected = isSelected;
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
    locker.paymentType = [[element child:@"paymenttype"] textAsInt];
    locker.operatingHours = [[element child:@"operatinghours"] text];
    locker.status = [[element child:@"status"] text];
    
    /* This string field can be equal to 'f' -> false, or 't' -> true */
    NSString *paymentavailable = [[element child:@"paymentavailable"] text];
    BOOL paymentAvailable = [paymentavailable isEqualToString:@"t"];
    locker.paymentAvailable = paymentAvailable;
    locker.type = [[element child:@"type"] text];
    
    return locker;
}

+ (TKParcelLocker *)lockerWithNSDictionary:(NSDictionary *)dictionary{
    TKParcelLocker *locker = [[TKParcelLocker alloc] init];
    
    locker.name = dictionary[@"name"];
    locker.postalCode = dictionary[@"postcode"];
    locker.province = dictionary[@"province"];
    locker.street = dictionary[@"street"];
    locker.buildingNumber = dictionary[@"buildingnumber"];
    locker.town = dictionary[@"town"];
    
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [dictionary[@"longitude"] doubleValue];
    coordinate.latitude = [dictionary[@"latitude"] doubleValue];
    locker.coordinate = coordinate;
    
    locker.locationDescription = dictionary[@"locationdescription"];
    locker.paymentPointDescription = dictionary[@"paymentpointdescr"];
    
    locker.parternId = [dictionary[@"partnerid"] integerValue];
    locker.paymentType = [dictionary[@"paymenttype"] integerValue];
    locker.operatingHours = dictionary[@"operatinghours"];
    locker.status = dictionary[@"status"];
    locker.paymentAvailable = [dictionary[@"paymentavailable"] boolValue];
    locker.type = dictionary[@"type"];
    
    return locker;
}

+ (NSString *)sqlTableName{
    return @"lockers";
}

+ (NSString *)sqlTableModel{
    return @"lockers (name TEXT NOT NULL, postalCode TEXT NOT NULL, province TEXT, street TEXT, buildingNumber TEXT, town TEXT, longitude DOUBLE, latitude DOUBLE, locationDescription TEXT, paymentPointDescription TEXT, parterId INTEGER, paymentType INTEGER, operatingHours TEXT, status TEXT, paymentAvailable INTEGER, type TEXT, isSelected INTEGER)";
}

+ (NSString *)sqlInsertFormat{
    return @"INSERT INTO lockers VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%f\", \"%f\", \"%@\", \"%@\", \"%d\", \"%d\", \"%@\", \"%@\", \"%d\", \"%@\",\"%d\")";
}

+ (NSString *)deselectSelectedStatement{
    return [NSString stringWithFormat:@"UPDATE %@ SET isSelected = 0 WHERE isSelected = 1 ", [self sqlTableName]];
}

- (NSString *)selectStatement{
    return [NSString stringWithFormat:@"UPDATE %@ SET isSelected = 1 WHERE name = '%@'", [TKParcelLocker sqlTableName], self.name];
}

- (NSString *)sqlInsert{
    NSString *format = [TKParcelLocker sqlInsertFormat];
    
    NSString *escapedLocationDescription = [self.locationDescription stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    NSString *escapedPaymentPointDescription = [self.paymentPointDescription stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    
    NSString *sqlInsertStatement = [NSString stringWithFormat:format,
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
                                    self.paymentType,
                                    self.operatingHours ?: @"",
                                    self.status ?: @"",
                                    self.paymentAvailable,
                                    self.type ?: @"",
                                    self.isSelected ? 1 : 0];
    
    return sqlInsertStatement;
}

#pragma mark - MKAnnotaion

- (NSString *)title{
    if(self.isClosest){
        return [NSString stringWithFormat:@"%@ (%.3fkm)", self.name, self.curentDistanceFromUser];
    }
    else{
        return [NSString stringWithFormat:@"%@", self.name];
    }
}

- (NSString *)subtitle{
    return [NSString stringWithFormat:@"%@, %@ %@", self.town ?: @"", self.street ?: @"", self.buildingNumber ?: @""];
}

#pragma mark - Description

- (NSString *)description{
    return [NSString stringWithFormat:@"%@, %@ %@ %@ %@",self.name, self.street,self.buildingNumber, self.town, TKNSStringFromCLLocationCoordinate2D(self.coordinate) ];
}

#pragma mark - IsEqual

- (BOOL)isEqual:(id)object{
    if (object == nil) {
        return NO;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    double epsilon = 0.000001;
    TKParcelLocker *locker = (TKParcelLocker *)object;
    BOOL nameEqual = [self.name isEqualToString:locker.name];
    CLLocationCoordinate2D first_cllc2d =  locker.coordinate;
    CLLocationCoordinate2D second_cllc2d =  locker.coordinate;
    
    BOOL coordinatesEqual = (fabs(first_cllc2d.latitude - second_cllc2d.latitude) <= epsilon &&
                             fabs(first_cllc2d.longitude - second_cllc2d.longitude) <= epsilon);
    
    return nameEqual && coordinatesEqual;
}

- (NSUInteger)hash{
    return (self.coordinate.latitude + self.coordinate.longitude) * 1000;
}

@end

NSString * TKNSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate){
    return [NSString stringWithFormat:@"(%f, %f)", coordinate.latitude, coordinate.longitude];
}