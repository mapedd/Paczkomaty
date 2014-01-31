//
//  TKAppDelegate.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKAppDelegate.h"
#import "TKParcelTestViewController.h"

@implementation TKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[TKParcelTestViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
