//
//  UserEventsController.h
//  Weez
//
//  Created by Molham on 09/01/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Event.h"
#import "WeezBaseViewController.h"

@interface UserEventsController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    Event *selectedLocation;
    NSMutableArray *eventsList;
    UITableView *locationsTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
    
}

@property (nonatomic, retain) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) Event *selectedLocation;

@end
