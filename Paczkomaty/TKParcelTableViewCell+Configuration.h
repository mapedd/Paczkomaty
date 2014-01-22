//
//  TKParcelTableViewCell+Configuration.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelTableViewCell.h"

@class TKParcelLocker;

@interface TKParcelTableViewCell (Configuration)
- (void)configureWithParcel:(TKParcelLocker *)locker;
@end
