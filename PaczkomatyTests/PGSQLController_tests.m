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
#import "TKLockerMockingFunctions.h"

@interface PGSQLController_tests : XCTestCase
@property (strong, nonatomic) PGMockSQLController *sqlController;
@end

@implementation PGSQLController_tests

#pragma mark - Helpers



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
    
    TKParcelLocker *importLocker = lockerWithName(@"ABS123",CLLocationCoordinate2DMake(12.12312, 51.23123));
    [self.sqlController importParcelsToDataBase:@[importLocker]];
    NSArray *exportedObjects = [self.sqlController exportParcelsFromDataBase];
    XCTAssertEqual([exportedObjects count], (NSUInteger)1, @"exactly one object in the db");
    TKParcelLocker *exportLocker = exportedObjects[0];
    XCTAssertEqualObjects(importLocker, exportLocker, @"objects should be equal");
}

- (void)testSearch{
    TKParcelLocker *locker1 = lockerWithName(@"ABS123",CLLocationCoordinate2DMake(12.12312, 51.23123));
    TKParcelLocker *locker2 = lockerWithName(@"QWE312",CLLocationCoordinate2DMake(54.54212, 12.9884));
    
    [self.sqlController importParcelsToDataBase:@[locker1, locker2]];
    NSArray *exportedObjects = [self.sqlController search:@"ABS123"];
    XCTAssertEqual([exportedObjects count], (NSUInteger)1, @"exactly one object in the db");
    TKParcelLocker *exportLocker = exportedObjects[0];
    XCTAssertEqualObjects(locker1, exportLocker, @"objects should be equal");
}

- (void)testRegionExport{
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(12.12312, 51.23123);
    
    TKParcelLocker *locker1 = lockerWithName(@"ABS123",location1);
    location1.latitude += 0.6;
    TKParcelLocker *locker2 = lockerWithName(@"QWE312",location1);
    
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
    
    TKParcelLocker *lockerA = lockerWithName(@"ABC1", CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2", CLLocationCoordinate2DMake(52.194727, 21.0236972));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3", CLLocationCoordinate2DMake(52.1949583, 21.01434));
    
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    TKParcelLocker *locker = [self.sqlController  closestLockerToLocation:searchLocation];
    
    XCTAssertEqualObjects(locker, lockerA, @"first locker should be closest");
    
}

- (void)testGettingSelectedLockerIfOneIsSelected{
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    lockerA.isSelected = YES;
    lockerB.isSelected = NO;
    lockerC.isSelected = NO;
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    TKParcelLocker *locker = [self.sqlController  lastSelectedLocker];
    
    XCTAssertEqualObjects(locker, lockerA, @"locker A should be returned");
    XCTAssertTrue(locker.isSelected, @"returned locker should be selected");
}

- (void)testGettingSelectedLockerIfNoneIsSelected{
    
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    TKParcelLocker *locker = [self.sqlController  lastSelectedLocker];
    
    XCTAssertNil(locker, @"nil should be returned");
}

- (void)testUpdatingTableWithName{
    
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    [self.sqlController importParcelsToDataBase:@[lockerA]];
    
    XCTAssertTrue([self.sqlController  updateLockersWithStatement:@"UPDATE lockers SET name = 'ABC2' WHERE name = 'ABC1'"], @"should end with success");
    
    NSArray *lockers = [self.sqlController exportParcelsFromDataBase];
    
    XCTAssertEqual([lockers count], (NSUInteger)1, @"");
    
    TKParcelLocker *locker = lockers[0];
    
    XCTAssertEqualObjects(locker.name, @"ABC2", @"name should be updated");
}

- (void)testSelectingIfNoneWasSelected{
    
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    XCTAssertTrue([self.sqlController setLockerAsSelected:lockerA], @"should update successfully");
    
    XCTAssertEqualObjects([self.sqlController lastSelectedLocker], lockerA, @"lockerA should be returned as selected");
}

- (void)testSelectingIfOtherWasSelected{
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    lockerA.isSelected = YES;
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    XCTAssertTrue([self.sqlController setLockerAsSelected:lockerB], @"should update successfully");
    
    XCTAssertEqualObjects([self.sqlController lastSelectedLocker], lockerB, @"lockerB should be returned as selected");
}

- (void)testGettingParcelWithNameIfItExist{
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    
    XCTAssertEqualObjects([self.sqlController parcelWithName:@"ABC2"], lockerB, @"lockerB should be returned");
}

- (void)testGettingParcelWithNameIfItNotExist{
    TKParcelLocker *lockerA = lockerWithName(@"ABC1",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerB = lockerWithName(@"ABC2",CLLocationCoordinate2DMake(52.197872, 21.022672));
    TKParcelLocker *lockerC = lockerWithName(@"ABC3",CLLocationCoordinate2DMake(52.197872, 21.022672));
    
    [self.sqlController importParcelsToDataBase:@[lockerA, lockerB, lockerC]];
    
    
    XCTAssertNil([self.sqlController parcelWithName:@"ABC4"]);
}

- (void)testGettingParcelWithNameIfNilParamter{
    XCTAssertThrows([self.sqlController parcelWithName:nil],@"should throw since name could not be nil");
}

@end
