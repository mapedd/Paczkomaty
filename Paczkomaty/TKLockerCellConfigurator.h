//
//  TKLockerCellConfigurator.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 19/03/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TKParcelLocker;
@interface TKLockerCellConfigurator : NSObject
- (void)configureCell:(UITableViewCell *)cell withLocker:(TKParcelLocker *)locker;
@end
