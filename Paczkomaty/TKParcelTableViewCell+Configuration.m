//
//  TKParcelTableViewCell+Configuration.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelTableViewCell+Configuration.h"
#import "TKParcelLocker.h"

@implementation TKParcelTableViewCell (Configuration)

- (void)configureWithParcel:(TKParcelLocker *)locker{
    self.textLabel.text = [NSString stringWithFormat:@"%@, %@ %@",locker.name,locker.street, locker.buildingNumber];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@",locker.postalCode, locker.town];
    
}
@end
