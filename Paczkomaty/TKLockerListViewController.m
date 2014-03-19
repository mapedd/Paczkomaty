//
//  TKViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKLockerListViewController.h"
#import "TKParcelLocker.h"
#import "PGSQLController.h"
#import "TKParcelTableViewCell.h"
#import "TKParcelViewContoller.h"
#import "UIViewController+Lockers.h"
#import "TKNetworkController.h"
#import "TKLockerHelper.h"
#import "TKParcelDetailViewController.h"
#import "TKLockerCellConfigurator.h"

@interface TKLockerListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *parcelLockers;

@property (strong, nonatomic) NSArray *searchResults;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UISearchDisplayController *searchDisplay;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) TKNetworkController *networkController;

@property (strong, nonatomic) TKParcelLocker *lastSelectedLocker;

@property (strong, nonatomic) TKLockerCellConfigurator *cellConfigurator;

@end

@implementation TKLockerListViewController

#pragma mark - NSObject

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.networkController cancelParcelLoading];
}

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    [self addToNotificationCenter];
    [self setTitleForState:TKLoadingStateIdle];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:TKLocalizedStringWithToken(@"screen-title.list") image:[self tabBarImage] tag:1];
    return self;
}

- (void)setTitleForState:(TKLoadingState)state{
    NSString *title;
    switch (state) {
        case TKLoadingStateIdle:
            title = TKLocalizedStringWithToken(@"screen-title.paczkomaty");
            break;
        case TKLoadingStateFetching:
            title = TKLocalizedStringWithToken(@"screen-title.fetching");
            break;
        case TKLoadingStateImporting:
            title = TKLocalizedStringWithToken(@"screen-title.importing");
            break;
            
        default:
            break;
    }
    self.navigationItem.title = title;
}

- (UIImage *)tabBarImage{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [UIImage imageNamed:@"list_ios7"];
    }else{
        return [UIImage imageNamed:@"list_ios6"];
    }
}

#pragma mark - UIViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.parcelLockers = [[self sqlController] exportParcelsFromDataBase];
    
    
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
    
    if (![[self networkController] isFetchingParcels]) {
        [self showActivityIndicator:NO];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchDataIfNeededOrReload];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.parcelLockers = nil;
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)addToNotificationCenter{
    NSNotificationCenter *c = [NSNotificationCenter  defaultCenter];
    SEL selector = @selector(notificationReceived:);
    [c addObserver:self
          selector:selector
              name:TKNetworkControllerFetchedLockerDataNotificaiton
            object:nil];
    [c addObserver:self
          selector:selector
              name:PGSQLControllerImportedDataNotificaiton
            object:nil];
    [c addObserver:self
          selector:selector
              name:PGSQLControllerImportStartNotificaiton
            object:nil];
}

- (void)get{
    if (![[self networkController] isFetchingParcels]) {
        [self setTitleForState:TKLoadingStateFetching];
        [[self networkController] getAndImportData:[self sqlController]];
        [self showActivityIndicator:YES];
    }
}

- (void)showActivityIndicator:(BOOL)show{
    UIBarButtonItem *barButtonItem;
    if (show) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [indicator setColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
        }
        else{
            [indicator setColor:[UIColor whiteColor]];
        }
        [indicator startAnimating];
    }
    else{
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(get)];
    }
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
}

- (void)fetchDataIfNeededOrReload{
    self.parcelLockers = [[self sqlController] exportParcelsFromDataBase];
    if(self.parcelLockers.count == 0){
        [self get];
    }else{
        [self reloadData];
    }
}

- (void)reloadData{
    self.parcelLockers = [[self sqlController] exportParcelsFromDataBase];
    self.lastSelectedLocker = [[self sqlController] lastSelectedLocker];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)presentError:(NSError *)error title:(NSString *)title{
    [[[UIAlertView alloc] initWithTitle:title
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

#pragma mark - Getters

- (TKNetworkController *)networkController{
    if (_networkController == nil) {
        _networkController = [TKNetworkController new];
    }
    return _networkController;
}

- (TKLockerCellConfigurator *)cellConfigurator{
    if (_cellConfigurator == nil) {
        _cellConfigurator = [TKLockerCellConfigurator new];
    }
    return _cellConfigurator;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.searchDisplay.searchResultsTableView) {
        return 1;
    }
    else if (self.lastSelectedLocker != nil){
        return 2;
    }
    else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        if (self.lastSelectedLocker != nil && section == 0) {
            return 1;
        }else{
            return self.parcelLockers.count;
        }
    }
    else if(tableView == self.searchDisplay.searchResultsTableView){
        return self.searchResults.count;
    }
    else{
        return 0;
    }
}


#pragma mark - UITableViewDataSource - CELL FOR ROW

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    
    TKParcelTableViewCell *cell = (TKParcelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TKParcelTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self.cellConfigurator configureCell:cell withLocker:[self tableView:tableView lockerAtIndexPath:indexPath]];
    
    return cell;
}

- (TKParcelLocker *)tableView:(UITableView *)tableView lockerAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array;
    if (tableView == self.tableView) {
        if (self.lastSelectedLocker != nil && indexPath.section == 0) {
            return self.lastSelectedLocker;
        }
        
        array = self.parcelLockers;
    }
    else if (tableView == self.searchDisplay.searchResultsTableView){
        array = self.searchResults;
    }
    return array[indexPath.row];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TKParcelViewContoller *parcel = (TKParcelViewContoller *)self.parentViewController.parentViewController;
    if ([parcel isKindOfClass:[TKParcelViewContoller class]]) {
        [parcel didSelectLocker:[self tableView:tableView lockerAtIndexPath:indexPath]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    TKParcelDetailViewController *detail = [[TKParcelDetailViewController alloc] init];
    detail.parcel = [self tableView:tableView lockerAtIndexPath:indexPath];
    [self.navigationController pushViewController:detail animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplay.searchResultsTableView) {
        return nil;
    }
    else if (self.lastSelectedLocker != nil) {
        if(section == 0){
            return TKLocalizedStringWithToken(@"section-title.last-selected-locker");
        }
        else{
            return TKLocalizedStringWithToken(@"section-title.all-lockers");
        }
    }
    else{
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.searchDisplay.searchResultsTableView) {
        return 0.0f;
    }
    else if (self.lastSelectedLocker != nil) {
        return 30.0f;
    }
    else{
        return 0.0f;
    }
}

#pragma mark - UISearchDisplayDelegate


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    self.searchResults = [[self sqlController] search:searchString];
    return YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    controller.searchResultsTableView.dataSource = self;
    controller.searchResultsTableView.delegate = self;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView{
    self.searchResults = nil;
}


#pragma mark - NSNotificationCenter

- (void)notificationReceived:(NSNotification *)note{
    if ([note.name isEqualToString:TKNetworkControllerFetchedLockerDataNotificaiton]) {
        BOOL success = [[note object] boolValue];
        if (!success) {
            NSError *error = [note userInfo][@"error"];
            [self presentError:error title:TKLocalizedStringWithToken(@"alert-title.cant-fetch-parcels")];
            [self setTitleForState:(TKLoadingStateIdle)];
            [self showActivityIndicator:NO];
        }
    }
    else if([note.name isEqualToString:PGSQLControllerImportStartNotificaiton]){
        [self setTitleForState:TKLoadingStateImporting];
    }
    else if([note.name isEqualToString:PGSQLControllerImportedDataNotificaiton]){
        [self setTitleForState:TKLoadingStateIdle];
        [self reloadData];
        [self showActivityIndicator:NO];
    }
}

@end
