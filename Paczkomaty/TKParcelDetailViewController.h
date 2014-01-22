//
//  TKParcelDetailViewController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TKParcelLocker;
@interface TKParcelDetailViewController : UIViewController
@property (strong, nonatomic) TKParcelLocker *parcel;
@end
