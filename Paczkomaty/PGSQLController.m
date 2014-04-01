//
//  PGSQLController.m
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import "PGSQLController.h"
#import "TKParcelLocker+Helpers.h"
#import "TKLockerHelper.h"

#ifdef DEBUG
#define DEBUG_SQLITE
#endif

#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

NSString *const PGSQLControllerImportStartNotificaiton = @"PGSQLControllerImportStartNotificaiton";
NSString *const PGSQLControllerImportedDataNotificaiton = @"PGSQLControllerImportedDataNotificaiton";

/* Error callback */
void errorLogCallback(void *pArg, int iErrCode, const char *zMsg);

#ifdef DEBUG_SQLITE
/* Profiling */
static void profile(void *context, const char *sql, sqlite3_uint64 ns);
#endif

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv);

@interface PGSQLController (){
    sqlite3 *_database;
}



/* Source : http://www.thismuchiknow.co.uk/?p=71 */


@property(strong, nonatomic) NSString *databasePath;

@property (strong, nonatomic) dispatch_queue_t queue;


@end


@implementation PGSQLController

- (void)dealloc {
    [self close];
}

- (BOOL)databaseConnectionExists{
    return _database != NULL;
}

- (BOOL)open{
    if (_database != NULL) {
        return YES;
    }
    
    int err = sqlite3_open([self.databasePath UTF8String], &_database);
    if (err != SQLITE_OK) {
        NSLog(@"can't open data base %d", err);
        return NO;
    }
    
    err = sqlite3_create_function(_database, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    if (err != SQLITE_OK) {
        NSLog(@"can't create distance function %d", err);
        return NO;
    }
#ifdef DEBUG_SQLITE
    sqlite3_profile(_database, &profile, NULL);
#endif
    
    return YES;
}

- (BOOL)close{
    if (_database == NULL) {
        return YES;
    }
    
    int err =  sqlite3_close(_database);
    
    if (err != SQLITE_OK) {
        NSLog(@"can't close data base %d", err);
        return YES;
    }
    
    _database = NULL;
    
    return YES;
    
}

- (id)init{
    
    self = [super init];
    
    if (self == nil) return nil;
#define USE_BUNDLE_DB
#ifdef USE_BUNDLE_DB
    /* Execute this code only when running app and not the tests */
    if (!TKIsRunningTests()) {
        /* If we haven't create db yet, we can copy bundled version and use it */
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.databasePath]) {
            NSBundle *bundle = TKPaczkomatyBundle();
            NSString *bundleDBPath = [bundle pathForResource:@"paczkomaty" ofType:@"db"];
            NSError * __autoreleasing error;
            if (![fm copyItemAtPath:bundleDBPath toPath:self.databasePath error:&error]) {
                NSLog(@"can't user bundled db file");
            }
        }
    }
#endif
    
    _queue = dispatch_queue_create([[self description] UTF8String], 0);
    
#ifdef DEBUG_SQLITE
    int err = sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback, NULL);
    if (err != SQLITE_OK) {
        NSLog(@"can't register error callback %d", err);
    }
#endif
    
    [self createDataBaseIfNotExist];
    
    return self;
    
}

- (BOOL)databaseModelIsValid{
    
    BOOL onlyOneGoodTable = NO;
    if ([self open]){
        sqlite3_stmt *statement = NULL;
        
        const char * select_stmt = [@"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%'" UTF8String];
        
        NSInteger status = sqlite3_prepare_v2(_database, select_stmt, -1, &statement, NULL);
        if (status == SQLITE_OK) {
            NSInteger i = 0;
            while (sqlite3_step(statement)==SQLITE_ROW) {
                char *name = (char *) sqlite3_column_text  (statement, 0);
                NSString *tableName = [[NSString alloc] initWithUTF8String:name];
                onlyOneGoodTable = i == 0 && [tableName isEqualToString:@"lockers"];
            }
            
            sqlite3_finalize(statement);
        }else{
            NSLog(@"can't comple statement (%ld)", (long)status);
        }
    }
    return onlyOneGoodTable;
}

- (id)debugQuickLookObject{
    return @"Hello!";
}

+ (NSString *)databaseFilePath{
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docsDir = dirPaths[0];
    
    return [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"paczkomaty.db"]];
}

- (NSString *)databasePath{
    if (_databasePath == nil) {
        // Build the path to the database file
        _databasePath = [PGSQLController databaseFilePath];
        
    }
    return _databasePath;
}

- (void)createDataBaseIfNotExist{
    
    if([self open]){
        char *errMsg;
        NSString *tableModel = [TKParcelLocker sqlTableModel];
        const char *sql_stmt = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", tableModel] UTF8String];
        
        if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            NSLog(@"Failed to create table %@", [[NSString alloc] initWithUTF8String:errMsg]);
        }
        else{
            NSLog(@"Create DB and added table 'lockers'");
        }
    }
    
    if (![self databaseModelIsValid]) {
        NSLog(@"data model is invalid");
    }
    
}

- (void)importParcelsToDataBase:(NSArray *)parcels{
    [self importParcelsToDataBase_PrecompiledStatement:parcels];
    return;
    
    CFAbsoluteTime importStartTime = CFAbsoluteTimeGetCurrent();
    
    NSError * __autoreleasing error;
    if ([self open])
    {
        [self postImportStart];
        sqlite3_stmt    *statement;
        char *errMsg;
        sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errMsg);
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
        
        sqlite3_exec(_database, "END TRANSACTION", NULL, NULL, &errMsg);
        
        
        CFAbsoluteTime importEndTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"import time for %lu items is %f sec", (unsigned long)parcels.count, importEndTime - importStartTime);
        [self postImportSuccess:YES error:nil];
        
    }else{
        error = [NSError errorWithDomain:@"com.paczkomaty.sql" code:-1 userInfo:nil];
        [self postImportSuccess:NO error:error];
    }
}

- (void)importParcelsToDataBase_PrecompiledStatement:(NSArray *)parcels{
    CFAbsoluteTime importStartTime = CFAbsoluteTimeGetCurrent();
    
    NSError * __autoreleasing error;
    if ([self open])
    {
        [self postImportStart];
        
        
        char *insert = "INSERT INTO lockers VALUES ("
        "@name,"                        // 1
        "@postalCode, "                 // 2
        "@province, "                   // 3
        "@street, "                     // 4
        "@buildingNumber, "             // 5
        "@town, "                       // 6
        "@longitude, "                  // 7
        "@latitude, "                   // 8
        "@locationDescription, "        // 9
        "@paymentPointDescription, "    // 10
        "@parterId, "                   // 11
        "@paymentType, "                // 12
        "@operatingHours, "             // 13
        "@status, "                     // 14
        "@paymentAvailable, "           // 15
        "@type, "                       // 16
        "@isSelected)";                 // 17
        
        
        int status;
        char *errMsg;
        
        sqlite3_stmt    *statement;
        status = sqlite3_prepare_v2(_database, insert ,-1, &statement, NULL);
        if (status != SQLITE_OK) {
            NSLog(@"can't compile statement");
            return;
        }
        
        status = sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &errMsg);
        if (status != SQLITE_OK) {
            NSLog(@"can't begin transaction %d, %s", status, errMsg);
            return;
        }
        
        for (TKParcelLocker *p in parcels) {
            
            sqlite3_bind_text(statement, 1, [[p name] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [[p postalCode] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [[p province] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [[p street] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [[p buildingNumber] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [[p town] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_double(statement, 7, p.coordinate.longitude);
            sqlite3_bind_double(statement, 8, p.coordinate.latitude);
            sqlite3_bind_text(statement, 9, [[p locationDescription] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 10, [[p paymentPointDescription] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 11, (int)[p parternId]);
            sqlite3_bind_int(statement, 12, [p paymentType]);
            sqlite3_bind_text(statement, 13, [[p operatingHours] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 14, [[p status] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 15, (int)[p paymentAvailable]);
            sqlite3_bind_text(statement, 16, [[p status] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(statement, 17, (int)[p isSelected]);
            
            
            status = sqlite3_step(statement);
            if (status != SQLITE_DONE){
                NSLog(@"error stepping : %d", status);
            }
            sqlite3_clear_bindings(statement);
            sqlite3_reset(statement);
        }

        
        status = sqlite3_exec(_database, "END TRANSACTION", NULL, NULL, &errMsg);
        if (status != SQLITE_OK) {
            NSLog(@"cant' end transaction %d %s", status, errMsg);
        }
        
        
        CFAbsoluteTime importEndTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"import time for %lu items is %f sec", (unsigned long)parcels.count, importEndTime - importStartTime);
        [self postImportSuccess:YES error:nil];
        
    }else{
        error = [NSError errorWithDomain:@"com.paczkomaty.sql" code:-1 userInfo:nil];
        [self postImportSuccess:NO error:error];
    }
}

- (void)postImportStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PGSQLControllerImportStartNotificaiton
                                                            object:nil
                                                          userInfo:nil];
    });
}

- (void)postImportSuccess:(BOOL)success error:(NSError *)error{
    NSDictionary *userInfo;
    if (error) {
        userInfo = @{@"error" : error};
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PGSQLControllerImportedDataNotificaiton
                                                            object:@(success)
                                                          userInfo:userInfo];
    });
}

- (NSArray *)exportParcelsFromDataBase{
    return [self exportParcelsFromDataBase:nil error:nil];
}

- (NSArray *)exportParcelsFromDataBase:(NSString *)searchQuery error:(NSError **)error{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    NSString *query = searchQuery ?: @"SELECT * FROM lockers ORDER BY name";
    
    sqlite3_stmt *statement;
    
    if ([self open]){
        
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

- (TKParcelLocker *)parcelWithName:(NSString *)parcelName{
    NSParameterAssert(parcelName);
    NSError * __autoreleasing error;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE name = '%@'", [TKParcelLocker sqlTableName], parcelName];
    NSArray *array = [self exportParcelsFromDataBase:query error:&error];
    if (!array) {
        NSLog(@"error exporting %@", error);
        return nil;
    }
    else{
        if ([array count] > 0) {
            return array[0];
        }
        else{
            return nil;
        }
    }
}

- (TKParcelLocker *)closestLockerToLocation:(CLLocation *)location{
    NSError * __autoreleasing error;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM lockers ORDER BY distance(longitude, latitude, %f, %f) LIMIT 10", location.coordinate.longitude,location.coordinate.latitude];
    NSArray *array = [self exportParcelsFromDataBase:query error:&error];
    
    TKParcelLocker *locker;
    
    if (array.count) {
        locker = array[0];
    }
    
    if (locker == nil) {
        return nil;
    }
    
    locker.isClosest = YES;
    [locker assignDistanceFromLocation:location];
    return locker;
}

- (TKParcelLocker *)lastSelectedLocker{
    NSError * __autoreleasing error;
    NSString *query = @"SELECT * FROM lockers WHERE isSelected = 1";
    NSArray *array = [self exportParcelsFromDataBase:query error:&error];
    
    TKParcelLocker *locker;
    
    if (array.count) {
        locker = array[0];
    }
    
    if (locker == nil) {
        return nil;
    }
    
    return locker;
}

- (BOOL)setLockerAsSelected:(TKParcelLocker *)locker{
    /* First we will deselect all lockers in the db */
    NSString *deselectStatement = [TKParcelLocker deselectSelectedStatement];
    BOOL success = [self updateLockersWithStatement:deselectStatement];
    if (!success) {
        return NO;
    }
    NSString *selectStatement = [locker selectStatement];
    success = [self updateLockersWithStatement:selectStatement];
    
    return success;
}

- (BOOL)updateLockersWithStatement:(NSString *)sqlStatement{
    BOOL success = NO;
    
    if ([self open]){
        char *errMsg;
        const char *sql_stmt = [sqlStatement UTF8String];
        
        if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK){
            NSLog(@"Failed to update table %@", [[NSString alloc] initWithUTF8String:errMsg]);
            success = NO;
        }
        else{
            NSLog(@"updated table with statement %@", sqlStatement);
            success = YES;
        }
    }
    return success;
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
    fprintf(stderr, "SQLite  Error : CODE (%d) MESSAGE %s\n", iErrCode, zMsg);
}
#ifdef DEBUG_SQLITE
void profile(void *context, const char *sql, sqlite3_uint64 ns){
    fprintf(stderr, "SQLite Profile : QUERY:%s, EXECUTION TIME %llu ms\r",sql, ns/1000000);
}
#endif

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
