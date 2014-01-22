//
//  TKParcelViewContoller.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelViewContoller.h"
#import "TKViewController.h"
#import "TKMapViewController.h"

@interface TKParcelViewContoller ()

@end

@implementation TKParcelViewContoller

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    
    
    TKViewController *vc1 = [TKViewController new];
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    TKMapViewController *vc2 = [TKMapViewController new];
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    
    [self setViewControllers:@[nc1,nc2]];
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end
