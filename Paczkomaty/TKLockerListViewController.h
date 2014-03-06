//
//  TKViewController.h
//  Paczkomaty
//
//  Created by Tomasz Kuźma on 07/01/14.
//  Copyright (c) 2014 mapedd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TKLoadingState) {
    TKLoadingStateIdle,
    TKLoadingStateFetching,
    TKLoadingStateImporting,
};

@interface TKLockerListViewController : UIViewController

@end
