//
//  TKNetworkController_tests.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 14/02/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TKNetworkController.h"

@interface TKNetworkController_tests : XCTestCase{
    TKNetworkController *network;
}

@end

@implementation TKNetworkController_tests

- (void)setUp{
    [super setUp];
    network = [[TKNetworkController alloc] init];
}

- (void)tearDown{
    network = nil;
    [super tearDown];
}

- (void)testNetworkRequestIsCreated{
    [network getAndImportData:nil];
    XCTAssertEqual([network.operationQueue operationCount],(NSUInteger)1, @"one network request should be created");
    
}

- (void)testCancelation{
    [network getAndImportData:nil];
    [network cancelParcelLoading];
    
    for (NSOperation *operation in [network.operationQueue operations]) {

        XCTAssertEqual([operation isCancelled], YES, @"all should be canceled");
    }

    
}

@end
