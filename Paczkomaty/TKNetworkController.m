//
//  TKNetworkController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKNetworkController.h"
#import <AFNetworking.h>
#import "TKParcelLocker.h"
#import <RXMLElement.h>
#import "PGSQLController.h"

NSString *const TKNetworkControllerFetchedLockerDataNotificaiton = @"TKNetworkControllerFetchedLockerDataNotificaiton";
NSString *const TKNetworkControllerImportedDataNotificaiton = @"TKNetworkControllerImportedDataNotificaiton";

@interface TKNetworkController ()

@property (weak, nonatomic) AFHTTPRequestOperation *operation;

@end

@implementation TKNetworkController
+ (TKNetworkController *)sharedController{
    
    static id _sharedController = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedController = [[self class] new];
    });
    return _sharedController;
}

- (BOOL)isFetchingParcels{
    return self.operation != nil;
}

- (void)getAndImportData{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __unsafe_unretained typeof(self) bself = self;
    manager.responseSerializer = serializer;
   self.operation =  [manager GET:@"http://api.paczkomaty.pl/?do=listmachines_xml&paymentavailable="
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSMutableArray *array = [NSMutableArray array];
             RXMLElement *element = [[RXMLElement alloc] initFromXMLData:responseObject];
             [element iterate:@"machine" usingBlock: ^(RXMLElement *e) {
                 TKParcelLocker *locker = [TKParcelLocker lockerWithXMLElement:e];
                 [array addObject:locker];
             }];
             
             
             [bself postFetchSuccess:YES error:nil];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [bself postFetchSuccess:YES error:nil];
         }];
}


- (void)postFetchSuccess:(BOOL)success error:(NSError *)error{
    NSDictionary *userInfo;
    if (error) {
        userInfo = @{@"error" : error};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TKNetworkControllerFetchedLockerDataNotificaiton
                                                        object:@(success)
                                                      userInfo:userInfo];
}

- (void)importLockersData:(NSArray *)lockers{
    PGSQLController *controller = [[PGSQLController alloc] init];
    [controller importParcelsToDataBase:lockers];
}

@end
