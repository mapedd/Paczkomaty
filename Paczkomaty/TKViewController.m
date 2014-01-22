//
//  TKViewController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKViewController.h"
#import "TKParcelLocker.h"
#import "PGSQLController.h"
#import "TKNetworkController.h"

@interface TKViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *parcelLockers;

@property (strong, nonatomic) NSArray *searchResults;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UISearchDisplayController *searchDisplay;

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation TKViewController

#pragma mark - NSObject

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init{
    self = [super initWithNibName:nil bundle:nil];
    if(!self)return nil;
    [self reloadData];
    [self addToNotificationCenter];
    self.title = NSLocalizedString(@"Paczkomaty",nil);
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"List",nil) image:[self tabBarImage] tag:1];
    return self;
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

#pragma mark - Private

- (void)addToNotificationCenter{
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    SEL selector = @selector(notificationReceived:);
    [c addObserver:self
          selector:selector
              name:TKNetworkControllerFetchedLockerDataNotificaiton
            object:nil];
    [c addObserver:self
          selector:selector
              name:TKNetworkControllerImportedDataNotificaiton
            object:nil];
}

- (void)get{
    if (![[TKNetworkController sharedController] isFetchingParcels]) {
        [[TKNetworkController sharedController] getAndImportData];
        [self showActivityIndicator:YES];
    }
}

- (void)showActivityIndicator:(BOOL)show{
    
    if (show) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
        [indicator startAnimating];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.navigationItem.leftBarButtonItem.enabled = !show;
}

- (void)reloadData{
    self.parcelLockers = [[PGSQLController sharedController] exportParcelsFromDataBase];
    [self.tableView reloadData];
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
    self.searchResults = [[PGSQLController sharedController] search:searchString];
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
        [self showActivityIndicator:NO];
    }else if([note.name isEqualToString:TKNetworkControllerImportedDataNotificaiton]){
        
    }
}

@end
