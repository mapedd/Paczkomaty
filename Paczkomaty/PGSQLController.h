//
//  PGSQLController.h
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>

extern NSString *const PGSQLControllerImportedDataNotificaiton;

@class TKParcelLocker;

@interface PGSQLController : NSObject
- (void)importParcelsToDataBase:(NSArray *)parcels;

- (NSArray *)exportParcelsFromDataBase;
- (NSArray *)exportParcelsFromRegion:(MKCoordinateRegion)region;
- (NSArray *)search:(NSString *)string;
- (TKParcelLocker *)closestLockerToLocation:(CLLocation *)location;
- (TKParcelLocker *)lastSelectedLocker;
- (BOOL)setLockerAsSelected:(TKParcelLocker *)locker;
- (BOOL)updateLockersWithStatement:(NSString *)sqlStatement;

- (BOOL)databaseConnectionExists;
- (BOOL)databaseModelIsValid;
- (NSString *)databasePath;
@end
