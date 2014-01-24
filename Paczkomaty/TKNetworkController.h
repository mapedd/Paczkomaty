//
//  TKNetworkController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

extern NSString *const TKNetworkControllerFetchedLockerDataNotificaiton;

@interface TKNetworkController : AFHTTPClient
+ (TKNetworkController *)sharedController;
- (void)getAndImportData;
- (BOOL)isFetchingParcels;
@end
