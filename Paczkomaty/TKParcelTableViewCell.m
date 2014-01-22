//
//  TKParcelTableViewCell.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelTableViewCell.h"

@implementation TKParcelTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self == nil) return nil;
    [self setup];
    return self;
}

- (void)setup{
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}

@end
