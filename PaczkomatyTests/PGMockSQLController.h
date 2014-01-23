//
//  PGMockSQLController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 23/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "PGSQLController.h"

@interface PGMockSQLController : PGSQLController
- (BOOL)removeDatabase;
@end
