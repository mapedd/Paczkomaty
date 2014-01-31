//
//  PGSQLController.m
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import "PGSQLController.h"
#import "TKParcelLocker.h"

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

NSString *const PGSQLControllerImportedDataNotificaiton = @"PGSQLControllerImportedDataNotificaiton";

void errorLogCallback(void *pArg, int iErrCode, const char *zMsg);

int executeCallback(void*pArg, int iErrCode, char** ,char**);

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv);

@interface PGSQLController (){
    sqlite3 *_database;
}

/* Source : http://www.thismuchiknow.co.uk/?p=71 */


@property(strong, nonatomic) NSString *databasePath;

@property (strong, nonatomic) dispatch_queue_t queue;


@end

static id _sharedController = nil;
static dispatch_once_t onceToken;

@implementation PGSQLController

+ (PGSQLController *)sharedController{
    
    dispatch_once(&onceToken, ^{
        if(_sharedController == nil)
            _sharedController = [[self class] new];
    });
    return _sharedController;
}

+ (void)setSharedController:(id)sharedController{
    onceToken = 0;
    _sharedController = sharedController;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (BOOL)databaseConnectionExists{
    return _database != NULL;
}

- (id)init{
    
    self = [super init];
    
    if (self == nil) return nil;
    
    [self addErrorCallbackToDataBase];
    
    _queue = dispatch_queue_create([[self description] UTF8String], 0);
    
    [self createDataBaseIfNotExist];
    
    return self;
    
}

- (id)debugQuickLookObject{
    return @"Hello!";
}

- (NSString *)databasePath{
    if (_databasePath == nil) {
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        // Build the path to the database file
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"paczkomaty.db"]];
        
    }
    return _databasePath;
}

- (void)createDataBaseIfNotExist{
    
    NSFileManager *filemgr = [[NSFileManager alloc] init];
    const char *dbpath = [self.databasePath UTF8String];
    if (![filemgr fileExistsAtPath: self.databasePath])
    {
        NSInteger status = sqlite3_open(dbpath, &_database);
        if (status == SQLITE_OK)
        {
            char *errMsg;
            NSString *tableModel = [TKParcelLocker sqlTableModel];
            const char *sql_stmt = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", tableModel] UTF8String];
            
            if (sqlite3_exec(_database, sql_stmt, &executeCallback, NULL, &errMsg) != SQLITE_OK){
                NSLog(@"Failed to create table %@", [[NSString alloc] initWithUTF8String:errMsg]);
            }
            else{
                NSLog(@"Create DB and added table 'lockers'");
            }
            if (_database != NULL) {
                sqlite3_close(NULL);
            }
            
        } else {
            NSLog(@"Failed to open/create database (%ld)", (long)status);
        }
    }
    else{
        NSLog(@"Data base exists");

    }
    
}

- (BOOL)databaseModelIsValid{
    const char *dbpath = [self.databasePath UTF8String];
    NSInteger status = sqlite3_open(dbpath, &_database);
    BOOL onlyOneGoodTable = NO;
    if (status == SQLITE_OK){
        sqlite3_stmt *statement = NULL;
        
        const char * select_stmt = [@"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%'" UTF8String];
        
        status = sqlite3_prepare_v2(_database, select_stmt, -1, &statement, NULL);
        if (status == SQLITE_OK) {
            NSInteger i = 0;
            while (sqlite3_step(statement)==SQLITE_ROW) {
                char *name = (char *) sqlite3_column_text  (statement, 0);
                NSString *tableName = [[NSString alloc] initWithUTF8String:name];
                onlyOneGoodTable = i == 0 && [tableName isEqualToString:@"lockers"];
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(_database);
        }else{
            NSLog(@"can't comple statement (%ld)", (long)status);
        }
    }
    return onlyOneGoodTable;
}

- (void)addErrorCallbackToDataBase{
    NSInteger status = sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback, NULL);
    if (status != SQLITE_OK) {
        NSLog(@"can't register error callback %ld", (long)status);
    }
}

- (void)importParcelsToDataBase:(NSArray *)parcels{
        
    const char *dbpath = [self.databasePath UTF8String];
    NSError * __autoreleasing error;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        for (TKParcelLocker *p in parcels) {
            NSString *insertSQL = [p sqlInsert];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            NSInteger status = sqlite3_prepare_v2(_database, insert_stmt,-1, &statement, NULL);
            
            if (status != SQLITE_OK) {
                error = [NSError errorWithDomain:@"com.paczkomaty.sql" code:1 userInfo:nil];
                [self postImportSuccess:NO error:error];
                return ;
            }
            
            status = sqlite3_step(statement);
            if (status == SQLITE_DONE)
            {
                //                    NSLog(@"added object with id = %@", p.name);
            }
            else{
                if (status == SQLITE_CONSTRAINT) {
                    NSLog(@"can't add object with id = %@, error: CONSTRAINT", p.name);
                }
                else if (status == SQLITE_MISUSE){
                    NSLog(@"can't add object with id = %@, error: MISUSE", p.name);
                }
                else{
                    NSLog(@"can't add object with id = %@, status = %ld", p.name, (long)status);
                }
                
            }
            sqlite3_finalize(statement);
        }
        
        
        sqlite3_close(_database);
        [self postImportSuccess:YES error:nil];
        
    }else{
        NSLog(@"Can't open database");
        error = [NSError errorWithDomain:@"com.paczkomaty.sql" code:-1 userInfo:nil];
        [self postImportSuccess:NO error:error];
    }
}

- (void)postImportSuccess:(BOOL)success error:(NSError *)error{
    NSDictionary *userInfo;
    if (error) {
        userInfo = @{@"error" : error};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PGSQLControllerImportedDataNotificaiton
                                                        object:@(success)
                                                      userInfo:userInfo];
}

- (NSArray *)exportParcelsFromDataBase{
    return [self exportParcelsFromDataBase:nil error:nil];
}

- (NSArray *)exportParcelsFromDataBase:(NSString *)searchQuery error:(NSError **)error{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    NSString *query = searchQuery ?: @"SELECT * FROM lockers ORDER BY name";
    
    sqlite3_stmt *statement;
    const char *dbpath = [self.databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK){
        // Adding distance function
        sqlite3_create_function(_database, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
        
        NSInteger status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
        
        if (status == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                TKParcelLocker *info = [TKParcelLocker lockerWithSQLStatement:statement];
                [retval addObject:info];
                
            }
            sqlite3_finalize(statement);
        }else{
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"SQLITE ERROR" code:status userInfo:nil];
            }
            return nil;
        }
        sqlite3_close(_database);
    }
    return retval;
}

- (NSArray *)exportParcelsFromRegion:(MKCoordinateRegion)mapRegion{
    
    CGFloat maxLatitude = mapRegion.center.latitude + mapRegion.span.latitudeDelta/2;
    CGFloat minLatitude = mapRegion.center.latitude - mapRegion.span.latitudeDelta/2;
    
    CGFloat maxLongitude = mapRegion.center.longitude+ mapRegion.span.longitudeDelta/2;
    CGFloat minLongitude = mapRegion.center.longitude- mapRegion.span.longitudeDelta/2;
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT * FROM lockers WHERE ((longitude < %f AND longitude > %f) AND (latitude < %f AND latitude > %f))",
                       maxLongitude,
                       minLongitude,
                       maxLatitude,
                       minLatitude];
    
    NSError * __autoreleasing error;
    NSArray *array = [self exportParcelsFromDataBase:query error:&error];
    return array;
}

- (TKParcelLocker *)closestLockerToLocation:(CLLocation *)location{
    NSError * __autoreleasing error;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM lockers ORDER BY distance(latitude, longitude, %f, %f)", location.coordinate.longitude,location.coordinate.latitude];
    NSArray *array = [self exportParcelsFromDataBase:query error:&error];
    return [array lastObject];
}

- (NSArray *)search:(NSString *)string{
    if (string.length == 0) {
        return @[];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM lockers WHERE name LIKE '%%%@%%' OR town LIKE '%%%@%%' OR street LIKE '%%%@%%'",string ,string,string];
    NSError * __autoreleasing error;
    NSArray *results = [self exportParcelsFromDataBase:query error:&error];
    if (results == nil) {
        NSLog(@"%@", error);
        return @[];
    }
    return results;
}

@end


void errorLogCallback(void *pArg, int iErrCode, const char *zMsg){
    fprintf(stderr, "(%d) %s\n", iErrCode, zMsg);
}

int executeCallback(void*pArg, int iErrCode, char** something1,char** something2){
    return 1;
}

void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv){
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = DEG2RAD(lat1);
    double lat2rad = DEG2RAD(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);
}
