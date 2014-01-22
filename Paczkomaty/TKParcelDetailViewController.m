//
//  TKParcelDetailViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 22/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKParcelDetailViewController.h"
#import "TKParcelView.h"
#import "TKParcelLocker.h"

@interface TKParcelDetailViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) TKParcelView *parcelView;
@end

@implementation TKParcelDetailViewController

#pragma mark - NSObject

- (id)init{
    self = [super init];
    if (self == nil) return nil;
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    self.parcelView = [[TKParcelView alloc] initWithFrame:self.view.bounds];
    self.parcelView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrollView addSubview:self.parcelView];
    self.parcelView.scrollView = self.scrollView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select",nil)
                                                               style:(UIBarButtonItemStyleBordered)
                                                              target:self
                                                              action:@selector(select:)];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List",nil)
                                                                               style:(UIBarButtonItemStyleBordered)
                                                                              target:nil
                                                                              action:nil];
    
    [self configureParcelView];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)select:(id)sender{
    
}

#pragma mark - Setters

- (void)setParcel:(TKParcelLocker *)parcel{
    if (_parcel != parcel) {
        _parcel = parcel;
        [self reloadData];
    }
}


- (void)reloadData{
    [self configureParcelView];
    self.title = self.parcel.name;
}

- (void)configureParcelView{
    self.parcelView.parcel = self.parcel;
}

@end
