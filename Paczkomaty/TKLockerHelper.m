//
//  TKLockerHelper.m
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 13/02/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import "TKLockerHelper.h"


NSBundle *TKPaczkomatyBundle(void) {
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
    
    if (TKPaczkomatyBundle() != nil) {
        localizedToken = NSLocalizedStringFromTableInBundle(token, @"Paczkomaty", TKPaczkomatyBundle(), @"");
    }
    return localizedToken;
}


BOOL TKIsRunningTests(void){
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"octest"] | [[injectBundle pathExtension] isEqualToString:@"xctest"];
}