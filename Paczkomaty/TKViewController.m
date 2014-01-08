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
#import "PGSQLController.h"

@interface TKViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *parcelLockers;

@property (strong, nonatomic) NSArray *searchResults;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) PGSQLController *controller;

@property (strong, nonatomic) UISearchDisplayController *searchDisplay;

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation TKViewController

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    [self reloadData];
    self.controller = [[PGSQLController alloc] init];
    self.parcelLockers = [self.controller exportParcelsFromDataBase];
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
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    [self.tableView setTableHeaderView:self.searchBar];
    
    self.searchDisplay  = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                            contentsController:self];
    self.searchDisplay.delegate = self;
    [self.searchDisplay setSearchResultsDataSource:self];
    
}

- (void)reloadData{
    self.parcelLockers = [self.controller exportParcelsFromDataBase];
    [self.tableView reloadData];
    if (self.parcelLockers.count > 0) {
        self.title = [NSString stringWithFormat:@"%@ (%ld)", NSLocalizedString(@"List",nil),(unsigned long)self.parcelLockers.count];
    }else{
        self.title = NSLocalizedString(@"List",nil);
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
             
             [bself.controller importParcelsToDataBase:array];
             [bself reloadData];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return self.parcelLockers.count;
    }
    else if(tableView == self.searchDisplay.searchResultsTableView){
        return self.searchResults.count;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSArray *array;
    if (tableView == self.tableView) {
        array = self.parcelLockers;
    }
    else if (tableView == self.searchDisplay.searchResultsTableView){
        array = self.searchResults;
    }
    
    TKParcelLocker *locker =array[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, (%@,%@)",locker.name,locker.town, locker.street];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f,%f (%@)",locker.coordinate.latitude,locker.coordinate.latitude,locker.operatingHours];
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

#pragma mark - UISearchDisplayDelegate


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    self.searchResults = [self.controller search:searchString];
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    controller.searchResultsTableView.dataSource = self;
    controller.searchResultsTableView.delegate = self;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView{
    self.searchResults = nil;
}
@end
