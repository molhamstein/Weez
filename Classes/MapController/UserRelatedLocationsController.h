//
//  UserRelatedLocationsController.h
//  Weez
//
//  Created by Molham on 25/09/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "WeezBaseViewController.h"
#import "Event.h"

@interface UserRelatedLocationsController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    Location *selectedLocation;
    Event *selectedEvent;
    NSMutableArray *listOfUserLocationsAndEvents;
    
    UITableView *locationsTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
    NSString *userId;
}

@property (nonatomic, retain) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) Location *selectedLocation;
@property (nonatomic, retain) Event *selectedEvent;
@property (nonatomic, retain) NSString *userId;

@end
