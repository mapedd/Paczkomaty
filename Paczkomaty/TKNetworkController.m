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

@property (assign, nonatomic) BOOL isFetchingData;

@property (strong, nonatomic) dispatch_queue_t importQueue;

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
    return self.isFetchingData;
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
    self.isFetchingData = YES;
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
                bself.isFetchingData = NO;
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [bself postFetchSuccess:YES error:error];
              bself.isFetchingData = NO;
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
    if (self.importQueue == nil) {
        self.importQueue = dispatch_queue_create("com.Paczkomaty.Import", DISPATCH_QUEUE_SERIAL);
    }
    
#define IMPORT_BACKGROUND_THREAD
    
#ifdef IMPORT_BACKGROUND_THREAD
    dispatch_queue_t queue = self.importQueue;
#else
    dispatch_queue_t queue = dispatch_get_main_queue();
#endif
    
    dispatch_async(queue, ^{
       [controller importParcelsToDataBase:lockers];
    });
}

@end
