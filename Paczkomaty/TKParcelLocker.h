//
//  TKParcelLocker.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <sqlite3.h>


NSString * TKNSStringFromCLLocationCoordinate2D(CLLocationCoordinate2D coordinate);

@class RXMLElement;

@interface TKParcelLocker : NSObject <MKAnnotation>

@property (readonly, strong, nonatomic) NSString *name;
@property (readonly, strong, nonatomic) NSString *postalCode;
@property (readonly, strong, nonatomic) NSString *province;
@property (readonly, strong, nonatomic) NSString *street;
@property (readonly, strong, nonatomic) NSString *buildingNumber;
@property (readonly, strong, nonatomic) NSString *town;

@property (readonly, assign, nonatomic) BOOL paymentAvailable;
@property (readonly, strong, nonatomic) NSString *operatingHours;
@property (readonly, strong, nonatomic) NSString *locationDescription;
@property (readonly, strong, nonatomic) NSString *paymentPointDescription;
@property (readonly, assign, nonatomic) long parternId;
@property (readonly, strong, nonatomic) NSString *paymentType;
@property (readonly, strong, nonatomic) NSString *type;
@property (readonly, strong, nonatomic) NSString *status;


@property (readwrite, assign, nonatomic) BOOL isClosest;
@property (readwrite, assign, nonatomic) BOOL isSelected;
/* In kilometers */
@property (readwrite, assign, nonatomic) CGFloat curentDistanceFromUser;

#pragma mark - MKAnnotation
@property (readonly, assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;


+ (TKParcelLocker *)lockerWithNSDictionary:(NSDictionary *)element;
+ (TKParcelLocker *)lockerWithXMLElement:(RXMLElement *)element;
+ (TKParcelLocker *)lockerWithSQLStatement:(sqlite3_stmt *)statement;
+ (NSString *)sqlTableName;
+ (NSString *)sqlTableModel;
+ (NSString *)deselectSelectedStatement;
- (NSString *)sqlInsert;
- (NSString *)selectStatement;

@end
