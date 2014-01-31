//
//  UIViewController+Lockers.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 31/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "UIViewController+Lockers.h"
#import "TKParcelLocker.h"
#import "PGSQLController.h"
#import "TKParcelViewContoller.h"

@implementation UIViewController (Lockers)
- (void)lockerControllerDidSelectLocker:(TKParcelLocker *)locker{
    TKParcelViewContoller *parcel = [self parcelViewController];
    [parcel didSelectLocker:locker];
}

- (TKParcelViewContoller *)parcelViewController{
    TKParcelViewContoller *vc = (TKParcelViewContoller *)self.parentViewController.parentViewController;
    return [vc isKindOfClass:[TKParcelViewContoller class]] ? vc : nil;
}

- (PGSQLController *)sqlController{
    return [[self parcelViewController] sqlController];
}
@end
