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

@interface PGSQLController ()

@property(strong, nonatomic) NSString *databasePath;

@property (strong, nonatomic) dispatch_queue_t queue;

@end

@implementation PGSQLController{
    sqlite3 *_database;
}

- (void)dealloc {
    sqlite3_close(_database);
}

- (id)init{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _queue = dispatch_queue_create([[self description] UTF8String], 0);
    __unsafe_unretained typeof(self) bself = self;
    
    dispatch_async(_queue, ^{
        [bself createDataBaseIfNotExist];
    });
    
    
    return self;
    
}

- (NSString *)databasePath{
    if (!_databasePath) {
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
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if (![filemgr fileExistsAtPath: self.databasePath])
    {
        const char *dbpath = [self.databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
        {
            char *errMsg;
            NSString *tableModel = [TKParcelLocker sqlTableModel];
            const char *sql_stmt = [[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", tableModel] UTF8String];
            
            
            if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            else{
                NSLog(@"Create DB and added table clients");
            }
            sqlite3_close(_database);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void)importParcelsToDataBase:(NSArray *)parcels{
    
    dispatch_async(_queue, ^{
        sqlite3_stmt    *statement;
        const char *dbpath = [self.databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
        {
            
            for (TKParcelLocker *p in parcels) {
                NSString *insertSQL = [p sqlInsert];
                
                const char *insert_stmt = [insertSQL UTF8String];
                
                sqlite3_prepare_v2(_database, insert_stmt,-1, &statement, NULL);
                NSInteger status = sqlite3_step(statement);
                if (status == SQLITE_DONE)
                {
                    NSLog(@"added client with id = %@", p.name);
                } else {
                    NSLog(@"can't add client with id = %@, status = %ld", p.name, (long)status);
                }
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(_database);
        }
    });
}

- (NSArray *)exportParcelsFromDataBase{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    NSString *query = @"SELECT * FROM lockers ORDER BY name";
    
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
        }
        sqlite3_close(_database);
    }
    return retval;
}

@end
