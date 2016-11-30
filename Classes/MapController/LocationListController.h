//
//  LocationListController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "Event.h"
#import <CoreLocation/CLLocationManager.h>
@import GooglePlacePicker;
#import "WeezBaseViewController.h"

@interface LocationListController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIAlertViewDelegate>
{
    NSMutableArray *fullLocationList;
    NSMutableArray *filteredList;
    NSString *locationId;
    NSString *eventId;
    Location *selectedLocation;
    Event *selectedEvent;
    UITableView *locationsTableView;
    UIView *searchView;
    UILabel *searchLabel;
    UITextField *searchTextField;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    GMSPlacePicker *_placePicker;
    CLLocationManager *locationManagr;
    Location *googlePlacesPickedLocation;
    BOOL limitToCloseLocationsOnly;
    BOOL limitToDefinedPlacesOnly;
}

@property (nonatomic, retain) Location *selectedLocation;
@property (nonatomic, retain) Location *googlePlacesPickedLocation;
@property (nonatomic, retain) Event *selectedEvent;
@property (nonatomic, retain) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) IBOutlet UIView *searchView;
@property (nonatomic, retain) IBOutlet UILabel *searchLabel;
@property (nonatomic, retain) IBOutlet UITextField *searchTextField;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic) BOOL limitToCloseLocationsOnly;
@property (nonatomic) BOOL limitToDefinedPlacesOnly;

- (void)setLocationId:(NSString*)locId withLocation:(Location*)location withEvent:(Event*)event;
- (IBAction)backgroundClick:(id)sender;

@end
