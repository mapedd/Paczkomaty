//
//  TKAppDelegate.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKAppDelegate.h"
#import "TKViewController.h"
#import "TKMapViewController.h"
#import "PGSQLController.h"



@implementation TKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    TKViewController *vc1 = [TKViewController new];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    TKMapViewController *vc2 = [TKMapViewController new];
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    [tabBar setViewControllers:@[nc1,nc2]];
    
    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];
    return YES;
}


- (PGSQLController *)controller{
    if (_controller == nil) {
        _controller = [[PGSQLController alloc] init];
    }
    return _controller;
}

+ (TKAppDelegate *)sharedDelegate{
    return [UIApplication sharedApplication].delegate;
}
@end
