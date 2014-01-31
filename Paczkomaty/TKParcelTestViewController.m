//
//  TKParcelTestViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 31/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelTestViewController.h"
#import "Paczkomaty.h"

@interface TKParcelTestViewController () <TKParcelViewContollerDelegate>

@end

@implementation TKParcelTestViewController

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Paczkomaty test",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select locker",nil)
                                                                              style:(UIBarButtonItemStyleBordered)
                                                                             target:self
                                                                             action:@selector(buttonTap1)];
    
    
    
}

- (void)buttonTap1{
    TKParcelViewContoller *parcel = [TKParcelViewContoller new];
    parcel.parcelDelegate = self;
    [self.navigationController presentViewController:parcel animated:YES completion:nil];
}

#pragma mark - TKParcelViewContollerDelegate


- (void)parcelController:(TKParcelViewContoller *)parcelViewController didSelectLocker:(TKParcelLocker *)locker{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:^{
                                                      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Selected locker : %@",nil), locker.name];
                                                     [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success",nil)
                                                                                 message:message
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil] show];
                                                  }];
}

- (void)parcelControllerWantCancel:(TKParcelViewContoller *)parcelViewController{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

@end
