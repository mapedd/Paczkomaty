//
//  TKParcelLocker_tests.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 23/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TKParcelLocker.h"
#import <RaptureXML/RXMLElement.h>


static NSString * parcelXML =
@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
@"<paczkomaty>"
@"%@"
@"</paczkomaty>";

static NSString * formatXML =
@"<machine>"
@"<name>%@</name>"
@"<type>%@</type>"
@"<postcode>%@</postcode>"
@"<province>%@</province>"
@"<street>%@</street>"
@"<buildingnumber>%@</buildingnumber>"
@"<town>%@</town>"
@"<latitude>%f</latitude>"
@"<longitude>%f</longitude>"
@"<paymentavailable>%@</paymentavailable>"
@"<status>%@</status>"
@"<locationdescription><![CDATA[%@]]></locationdescription>"
@"<operatinghours><![CDATA[%@]]></operatinghours>"
@"<paymentpointdescr><![CDATA[%@]]></paymentpointdescr>"
@"<partnerid>%ld</partnerid>"
@"<paymenttype>%@</paymenttype>"
@"</machine>";

NSString * machineXML(NSString *name,
                      NSString *type,
                      NSString *postCode,
                      NSString *province,
                      NSString *street,
                      NSString *buildingNumber,
                      NSString *town,
                      double latitude,
                      double longitude,
                      NSString *paymentAvailable,
                      NSString *status,
                      NSString *locationDescription,
                      NSString *operatingHours,
                      NSString *paymentPointDescription,
                      long parterId,
                      NSString *paymentType){
    return [NSString stringWithFormat:formatXML,
            name,
            type,
            postCode,
            province,
            street,
            buildingNumber,
            town,
            latitude,
            longitude,
            paymentAvailable,
            status,
            locationDescription,
            operatingHours,
            paymentPointDescription,
            parterId,
            paymentType];
}


@interface TKParcelLocker_tests : XCTestCase{
    NSString *name;
    NSString *type;
    NSString *postCode;
    NSString *province;
    NSString *street;
    NSString *buildingNumber;
    NSString *town;
    double latitude;
    double longitude;
    NSString *paymentAvailable;
    NSString *status;
    NSString *locationDescription;
    NSString *operatingHours;
    NSString *paymentPointDescription;
    long parterId;
    NSString *paymentType;
    
    NSString *lockersXML;

}

@end

@implementation TKParcelLocker_tests

- (void)setUp
{
    
    [super setUp];
    name = @"ALL123";
    type = @"Pack Machine";
    postCode = @"13-123";
    province = @"Łódzkie";
    street = @"Piłsudskiego";
    buildingNumber = @"2/4";
    town = @"Aleksandrów Łódzki";
    latitude = 51.81284;
    longitude = 19.31626;
    paymentAvailable = @"f";
    status = @"Operating";
    locationDescription = @"Przy markecie Polomarket";
    operatingHours = @"Paczkomat: 24/7";
    paymentPointDescription = @"Super opis";
    parterId = 0;
    paymentType = @"type";
    
    lockersXML =  [NSString stringWithFormat:parcelXML, machineXML(name,
                                                            type,
                                                            postCode,
                                                            province,
                                                            street,
                                                            buildingNumber,
                                                            town,
                                                            latitude,
                                                            longitude,
                                                            paymentAvailable,
                                                            status,
                                                            locationDescription,
                                                            operatingHours,
                                                            paymentPointDescription,
                                                            parterId,
                                                            paymentType)];
}

- (void)tearDown
{
    name = nil;
    type = nil;
    postCode = nil;
    province = nil;
    street = nil;
    buildingNumber = nil;
    town = nil;
    latitude = 0.0;
    longitude = 0.0f;
    paymentAvailable = nil;
    status = nil;
    locationDescription = nil;
    operatingHours = nil;
    paymentPointDescription = nil;
    parterId = 0;
    paymentType = nil;
    lockersXML = nil;
    [super tearDown];
}

- (void)testXMLData{
    NSData *data = [lockersXML dataUsingEncoding:NSUTF8StringEncoding];
    RXMLElement *element = [[RXMLElement alloc] initFromXMLData:data];
    XCTAssertNotNil(element, @"data should be parsable XML file");
}

- (void)testXMLCreation{
    
    
    NSData *data = [lockersXML dataUsingEncoding:NSUTF8StringEncoding];
    
    RXMLElement *element = [[RXMLElement alloc] initFromXMLData:data];
    
    [element iterate:@"machine" usingBlock: ^(RXMLElement *e) {
        TKParcelLocker *locker = [TKParcelLocker lockerWithXMLElement:e];
        XCTAssertEqualObjects(locker.name, name, @"name should be equal");
        XCTAssertEqualObjects(locker.type, type, @"type should be equal");
        XCTAssertEqualObjects(locker.province, province, @"province should be equal");
        XCTAssertEqualObjects(locker.postalCode, postCode, @"postCode should be equal");
        XCTAssertEqualObjects(locker.street, street, @"street should be equal");
        XCTAssertEqualObjects(locker.buildingNumber, buildingNumber, @"buildingNumber should be equal");

        XCTAssertEqual(locker.coordinate.longitude, longitude, @"longitude should be equal");
        XCTAssertEqual(locker.coordinate.latitude, latitude, @"latitude should be equal");
        
        XCTAssertEqual(locker.paymentAvailable, YES, @"paymentAvailable should be equal");
        
        
        XCTAssertEqualObjects(locker.status, status, @"status should be equal");
        XCTAssertEqualObjects(locker.locationDescription, locationDescription, @"locationDescription should be equal");
        XCTAssertEqualObjects(locker.operatingHours, operatingHours, @"operatingHours should be equal");
        XCTAssertEqualObjects(locker.paymentPointDescription, paymentPointDescription, @"paymentPointDescription should be equal");
        
        XCTAssertEqual(locker.parternId, parterId, @"partnerId should be equal");
        XCTAssertEqualObjects(locker.paymentType, paymentType, @"paymentType should be equal");
    }];
}

- (void)testExample
{
    XCTAssertEqual(1, 1, "hello");
    
}

@end
