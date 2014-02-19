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

@interface TKNetworkController ()

@property (weak, nonatomic) AFHTTPRequestOperation *operation;

@end

@implementation TKNetworkController


- (void)dealloc{
    
}

- (id)init{
    NSURL *baseURL = [NSURL URLWithString:@"http://api.paczkomaty.pl"];
    self = [super initWithBaseURL:baseURL];
    if(self == nil)return nil;
    
    [self registerHTTPOperationClass:[AFXMLRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"text/html"];
    return self;
}

- (BOOL)isFetchingParcels{
    return self.operation != nil;
}

+ (NSString *)allParcelsPath{
    return @"?do=listmachines_xml&paymentavailable=";
}

- (void)cancelParcelLoading{
    NSString *method = @"GET";
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        
        BOOL hasMatchingMethod = !method || [method isEqualToString:[[(AFHTTPRequestOperation *)operation request] HTTPMethod]];
        
        if (hasMatchingMethod) {
            AFHTTPRequestOperation *afOperation = (AFHTTPRequestOperation *)operation;
            [afOperation cancel];
            afOperation.completionBlock = nil;
        }
    }
    
}

- (void)getAndImportData:(PGSQLController *)controller{
    __unsafe_unretained typeof(self) bself = self;
    
    [self getPath:[TKNetworkController allParcelsPath]
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (controller != nil) {
                  NSMutableArray *array = [NSMutableArray array];
                  RXMLElement *element = [[RXMLElement alloc] initFromXMLData:responseObject];
                  [element iterate:@"machine" usingBlock: ^(RXMLElement *e) {
                      TKParcelLocker *locker = [TKParcelLocker lockerWithXMLElement:e];
                      [array addObject:locker];
                  }];
                  
                  [bself importLockersData:[NSArray arrayWithArray:array] withController:controller];
                  [bself postFetchSuccess:YES error:nil];
              }else{
                  [bself postFetchSuccess:NO error:nil];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [bself postFetchSuccess:YES error:error];
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

- (void)importLockersData:(NSArray *)lockers withController:(PGSQLController *)controller{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [controller importParcelsToDataBase:lockers]; 
    });
}

@end
