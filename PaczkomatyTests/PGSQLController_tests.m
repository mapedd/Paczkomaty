//
//  PGSQLController_tests.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 23/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PGMockSQLController.h"
#import "TKParcelLocker.h"

@interface PGSQLController_tests : XCTestCase
@property (strong, nonatomic) PGMockSQLController *sqlController;
@end

@implementation PGSQLController_tests

#pragma mark - Helpers

- (TKParcelLocker *)lockerWithName:(NSString *)name location:(CLLocationCoordinate2D)location{
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

#pragma mark - Setup

- (void)setUp{
    [super setUp];
    self.sqlController = [[PGMockSQLController alloc] init];
}

- (void)tearDown{
    XCTAssertTrue([self.sqlController removeDatabase], @"data base should be removed each time");
    self.sqlController = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testDataBaseExist{
    XCTAssertTrue([self.sqlController databaseConnectionExists], @"should be created when initializing sql controller");
}

- (void)testDataBaseModel{
    XCTAssertTrue([self.sqlController databaseModelIsValid], @"should have valid model");
}

- (void)testImportExport{
    
    TKParcelLocker *importLocker = [self lockerWithName:@"ABS123" location:CLLocationCoordinate2DMake(12.12312, 51.23123)];
    [self.sqlController importParcelsToDataBase:@[importLocker]];
    NSArray *exportedObjects = [self.sqlController exportParcelsFromDataBase];
    XCTAssertEqual([exportedObjects count], (NSUInteger)1, @"exactly one object in the db");
    TKParcelLocker *exportLocker = exportedObjects[0];
    XCTAssertEqualObjects(importLocker, exportLocker, @"objects should be equal");
}

- (void)testSearch{
    TKParcelLocker *locker1 = [self lockerWithName:@"ABS123" location:CLLocationCoordinate2DMake(12.12312, 51.23123)];
    TKParcelLocker *locker2 = [self lockerWithName:@"QWE312" location:CLLocationCoordinate2DMake(54.54212, 12.9884)];
    
    [self.sqlController importParcelsToDataBase:@[locker1, locker2]];
    NSArray *exportedObjects = [self.sqlController search:@"ABS123"];
    XCTAssertEqual([exportedObjects count], (NSUInteger)1, @"exactly one object in the db");
    TKParcelLocker *exportLocker = exportedObjects[0];
    XCTAssertEqualObjects(locker1, exportLocker, @"objects should be equal");
}

- (void)testRegionExport{
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(12.12312, 51.23123);
    
    TKParcelLocker *locker1 = [self lockerWithName:@"ABS123" location:location1];
    location1.latitude += 0.6;
    TKParcelLocker *locker2 = [self lockerWithName:@"QWE312" location:location1];
    
    [self.sqlController importParcelsToDataBase:@[locker1, locker2]];
    MKCoordinateRegion region;
    region.center = location1;
    region.span.latitudeDelta = 0.5;
    region.span.longitudeDelta = 0.5;
    NSArray *exportedObjects = [self.sqlController exportParcelsFromRegion:region];
    TKParcelLocker *exportLocker = (TKParcelLocker *)exportedObjects[0];
    XCTAssertEqualObjects(exportLocker, locker2, @"only first locker should be found");
    
}

- (void)testClosestPoint{
    
    CLLocationCoordinate2D startLocation = CLLocationCoordinate2DMake(52.1971083, 21.02257);
    CLLocation *searchLocation = [[CLLocation alloc] initWithLatitude:startLocation.latitude longitude:startLocation.longitude];
    
    TKParcelLocker *lockerA = [self lockerWithName:@"ABC1" location:CLLocationCoordinate2DMake(52.197872, 21.022672)];
    
    TKParcelLocker *lockerB = [self lockerWithName:@"ABC2" location:CLLocationCoordinate2DMake(52.194727, 21.0236972)];
    
    TKParcelLocker *lockerC = [self lockerWithName:@"ABC3" location:CLLocationCoordinate2DMake(52.1949583, 21.01434)];
    
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    TKParcelLocker *locker = [self.sqlController  closestLockerToLocation:searchLocation];

    XCTAssertEqualObjects(locker, lockerA, @"first locker should be closest");
    
}

@end
