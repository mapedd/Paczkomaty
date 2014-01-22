//
//  PGSQLController.m
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import "PGSQLController.h"
#import <sqlite3.h>
#import "TKParcelLocker.h"

NSString *const PGSQLControllerImportedDataNotificaiton = @"PGSQLControllerImportedDataNotificaiton";

void errorLogCallback(void *pArg, int iErrCode, const char *zMsg);

int executeCallback(void*pArg, int iErrCode, char** ,char**);

@interface PGSQLController ()

@property(strong, nonatomic) NSString *databasePath;

@property (strong, nonatomic) dispatch_queue_t queue;

@property (assign, nonatomic) sqlite3 *database;

@end



@implementation PGSQLController

+ (PGSQLController *)sharedController{
    
    static id _sharedController = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedController = [[self class] new];
    });
    return _sharedController;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (id)init{
    
    self = [super init];
    
    if (self == nil) return nil;
    
    [self addErrorCallbackToDataBase];
    
    _queue = dispatch_queue_create([[self description] UTF8String], 0);
    __unsafe_unretained typeof(self) bself = self;
    
    dispatch_async(_queue, ^{
        [bself createDataBaseIfNotExist];
    });
    
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
            NSLog(@"Failed to open/create database (%d)", status);
        }
    }
    else{
        NSLog(@"Data base exists");
        
        NSInteger status = sqlite3_open(dbpath, &_database);
        if (status == SQLITE_OK){
            sqlite3_stmt *statement = NULL;
            
            const char * select_stmt = [@"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%'" UTF8String];
            
            status = sqlite3_prepare_v2(_database, select_stmt, -1, &statement, NULL);
            if (status == SQLITE_OK) {
                
                while (sqlite3_step(statement)==SQLITE_ROW) {
                    char *name = (char *) sqlite3_column_text  (statement, 0);
                    NSLog(@"table %@", [[NSString alloc] initWithUTF8String:name]);
                }
                
                sqlite3_finalize(statement);
                sqlite3_close(_database);
            }else{
                NSLog(@"can't comple statement (%d)", status);
            }
        }
    }
    
}

- (void)addErrorCallbackToDataBase{
    NSInteger status = sqlite3_config(SQLITE_CONFIG_LOG, errorLogCallback, NULL);
    if (status != SQLITE_OK) {
        NSLog(@"can't register error callback %d", status);
    }
}

- (void)importParcelsToDataBase:(NSArray *)parcels{
    
    dispatch_async(_queue, ^{
        
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
    });
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