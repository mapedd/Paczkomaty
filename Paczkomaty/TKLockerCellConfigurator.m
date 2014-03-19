//
//  TKLockerCellConfigurator.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 19/03/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKLockerCellConfigurator.h"
#import "TKParcelLocker.h"

static NSString *const TKParcelTextLabelTextKey = @"TKParcelTextLabelTextKey";
static NSString *const TKParcelDetailLabelTextKey = @"TKParcelDetailLabelTextKey";

@interface TKLockerCellConfigurator ()

@property (strong, nonatomic) NSMutableDictionary *cachedStrings;
@property (strong, nonatomic) NSDictionary *attrs;

@end

@implementation TKLockerCellConfigurator

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (id)init{
    self = [super init];
    if(self == nil)return nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(memoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    return self;
}

- (void)configureCell:(UITableViewCell *)cell withLocker:(TKParcelLocker *)locker{
    NSDictionary *lockerData = [self dataForLocker:locker];
    cell.textLabel.text = lockerData[TKParcelTextLabelTextKey];
    cell.detailTextLabel.text = lockerData[TKParcelDetailLabelTextKey];

}

- (NSDictionary *)attrs{
    if (_attrs == nil) {
        _attrs = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.122 green:0.514 blue:0.984 alpha:1.000]};
    }
    return _attrs;
}

- (NSMutableDictionary *)cachedStrings{
    if (_cachedStrings == nil) {
        _cachedStrings = [NSMutableDictionary new];
    }
    return  _cachedStrings;
}

- (NSDictionary *)dataForLocker:(TKParcelLocker *)locker{
    NSDictionary *dataDict = self.cachedStrings[locker.name];
    if (dataDict == nil) {
        
        static NSString *format1 = @"%@, %@ %@";
        static NSString *format2 = @"%@,%@";

        NSString *string = [NSString stringWithFormat:format1,locker.name,locker.street, locker.buildingNumber];
        
        dataDict = (@{
                      TKParcelTextLabelTextKey : string,
                      TKParcelDetailLabelTextKey : [NSString stringWithFormat:format2,locker.postalCode, locker.town]
                      });
        self.cachedStrings[locker.name] = dataDict;
    }
    
    return dataDict;
    

}

- (void)memoryWarning:(NSNotification *)note{
    self.cachedStrings = nil;
    self.attrs = nil;
}

@end
