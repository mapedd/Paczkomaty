//
//  TKLockerHelper.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 13/02/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKLockerHelper.h"


NSBundle *paczkomatyBundle(void) {
    static NSBundle* bundle = nil;
    if (bundle == nil) {
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"Paczkomaty.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    return bundle;
}


NSString *TKLocalizedStringWithToken(NSString *token){
    NSString *localizedToken = token;
    
    if (paczkomatyBundle() != nil) {
        localizedToken = NSLocalizedStringFromTableInBundle(token, @"Paczkomaty", paczkomatyBundle(), @"");
    }
    return localizedToken;
}

