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
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@ %@",locker.name,locker.street, locker.buildingNumber]];;
    if (locker.paymentAvailable) {
        NSAttributedString *paymentAvailable = [[NSAttributedString alloc] initWithString:@" ($)" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.122 green:0.514 blue:0.984 alpha:1.000]}];
        [string appendAttributedString:paymentAvailable];
    }
    self.textLabel.attributedText = string;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@",locker.postalCode, locker.town];
    
}
@end
