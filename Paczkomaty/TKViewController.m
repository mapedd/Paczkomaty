//
//  TKViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKViewController.h"
#import <AFNetworking.h>
#import <RXMLElement.h>
#import "TKParcelLocker.h"

@interface TKViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *parcelLockers;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation TKViewController

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    [self reloadData];
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(get)];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.tableView];
}

- (void)reloadData{
    [self.tableView reloadData];
    if (self.parcelLockers.count > 0) {
        self.title = [NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"Paczkomaty",nil),(unsigned long)self.parcelLockers.count];
    }else{
        self.title = NSLocalizedString(@"Paczkomaty",nil);
    }
}

- (void)get{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    __unsafe_unretained typeof(self) bself = self;
    manager.responseSerializer = serializer;
    [manager GET:@"http://api.paczkomaty.pl/?do=listmachines_xml&paymentavailable="
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSMutableArray *array = [NSMutableArray array];
             RXMLElement *element = [[RXMLElement alloc] initFromXMLData:responseObject];
             [element iterate:@"machine" usingBlock: ^(RXMLElement *e) {
                 TKParcelLocker *locker = [TKParcelLocker lockerWithXMLElement:e];
                 [array addObject:locker];
             }];
             
             bself.parcelLockers = [NSArray arrayWithArray:array];
             [bself reloadData];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.parcelLockers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TKParcelLocker *locker = self.parcelLockers[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, (%@,%@)",locker.name,locker.town, locker.street];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f,%f (%@)",locker.location.latitude,locker.location.latitude,locker.operatingHours];
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}
@end
