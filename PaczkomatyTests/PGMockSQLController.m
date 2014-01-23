//
//  PGMockSQLController.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 23/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "PGMockSQLController.h"

@implementation PGMockSQLController

- (BOOL)removeDatabase{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager removeItemAtPath:[self databasePath] error:nil];
}
- (NSString *)databasePath{
    return [NSString stringWithFormat:@"%@test_DB", [super databasePath]];
}
@end
