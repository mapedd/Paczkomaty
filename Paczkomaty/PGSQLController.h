//
//  PGSQLController.h
//  Perfect Gym
//
//  Created by Tomasz Kuźma on 10/12/13.
//  Copyright (c) 2013 Creadhoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGSQLController : NSObject
- (void)importParcelsToDataBase:(NSArray *)parcels;
- (NSArray *)exportParcelsFromDataBase;
@end
