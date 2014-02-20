//
//  TKParcelViewController_tests.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 20/02/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TKParcelViewContoller.h"
#import "TKParcelLocker.h"
#import "PGMockSQLController.h"
#import "TKLockerMockingFunctions.h"

@interface TKParcelViewController_tests : XCTestCase{
    TKParcelViewContoller *lockerViewController;
    PGMockSQLController *sqlController;
}

@end

@implementation TKParcelViewController_tests

- (void)setUp{
    [super setUp];
    lockerViewController = [TKParcelViewContoller new];
    sqlController = [PGMockSQLController new];
}

- (void)tearDown{
    lockerViewController = nil;
    [sqlController removeDatabase];
    sqlController = nil;
    [super tearDown];
}

- (void)testCreation{
    XCTAssertNotNil(lockerViewController);
}

- (void)testSettingSelectedLocker{
    TKParcelLocker *locker = lockerWithName(@"ABC1", CLLocationCoordinate2DMake(12.0, 43.0));
    [sqlController importParcelsToDataBase:@[locker]];
    [lockerViewController setValue:sqlController forKeyPath:@"sqlController"];
    [lockerViewController didSelectLocker:locker];
    XCTAssertEqualObjects(locker, [sqlController lastSelectedLocker], @"should be equal");
}

@end
