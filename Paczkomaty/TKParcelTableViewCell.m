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
    self.contentView.opaque = YES;
    self.textLabel.backgroundColor = [UIColor whiteColor];
    self.textLabel.opaque = YES;
    self.detailTextLabel.backgroundColor = [UIColor whiteColor];
    self.detailTextLabel.opaque = YES;
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

@end
