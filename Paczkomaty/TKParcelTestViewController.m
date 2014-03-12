//
//  TKParcelTestViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 31/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelTestViewController.h"
#import "TKLockerHelper.h"
#import "Paczkomaty.h"


#ifdef DEBUG
//#define DELETE_CACHE_AT_STARTUP
#endif

@interface TKParcelTestViewController () <TKParcelViewContollerDelegate>

@end

@implementation TKParcelTestViewController

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    
#ifdef DELETE_CACHE_AT_STARTUP
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [PGSQLController databaseFilePath];
    if ([fm fileExistsAtPath:filePath]) {
        NSLog(@"old data base removed");
        [fm removeItemAtPath:filePath error:nil];
    }
#endif
    
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = TKLocalizedStringWithToken(@"screen-title.demo");
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TKLocalizedStringWithToken(@"button-title.select-locker")
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
                                                      NSString *message = [NSString stringWithFormat:TKLocalizedStringWithToken(@"alert-message.selected-locker"), locker.name];
                                                     [[[UIAlertView alloc] initWithTitle:TKLocalizedStringWithToken(@"alert-title.success")
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
