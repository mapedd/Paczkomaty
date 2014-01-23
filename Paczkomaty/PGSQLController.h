//
//  PGSQLController.h
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
extern NSString *const PGSQLControllerImportedDataNotificaiton;

@interface PGSQLController : NSObject
+ (PGSQLController *)sharedController;
+ (void)setSharedController:(id)sharedController;

- (void)importParcelsToDataBase:(NSArray *)parcels;

- (NSArray *)exportParcelsFromDataBase;
- (NSArray *)exportParcelsFromRegion:(MKCoordinateRegion)region;
- (NSArray *)search:(NSString *)string;
@end
