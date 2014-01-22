//
//  TKAppDelegate.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PGSQLController;
@interface TKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PGSQLController *controller;

+ (TKAppDelegate *)sharedDelegate;
@end
