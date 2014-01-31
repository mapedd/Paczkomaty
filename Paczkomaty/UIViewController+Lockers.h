//
//  UIViewController+Lockers.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 31/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKParcelLocker, TKParcelViewContoller, PGSQLController;

@interface UIViewController (Lockers)
- (void)lockerControllerDidSelectLocker:(TKParcelLocker *)locker;
- (TKParcelViewContoller *)parcelViewController;
- (PGSQLController *)sqlController;
@end
