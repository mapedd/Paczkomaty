//
//  TKNetworkController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TKNetworkControllerFetchedLockerDataNotificaiton;
extern NSString *const TKNetworkControllerImportedDataNotificaiton;

@interface TKNetworkController : NSObject
+ (TKNetworkController *)sharedController;
- (void)getAndImportData;
- (BOOL)isFetchingParcels;
@end
