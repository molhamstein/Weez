//
//  UserOwnedLocationsController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "WeezBaseViewController.h"

@interface UserOwnedLocationsController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    Location *selectedLocation;
    NSMutableArray *myLocationsList;
    UITableView *locationsTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
    
    BOOL isSelectLocatonModeEnabled;
}

@property (nonatomic, retain) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) Location *selectedLocation;
@property BOOL isSelectLocatonModeEnabled;

@end
