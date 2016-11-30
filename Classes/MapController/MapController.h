//
//  MapController.h
//  Weez
//
//  Created by Molham on 6/14/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Location.h"
#import "Timeline.h"
#import "Event.h"
@import GoogleMaps;

typedef enum{
    detailsViewStatusExpanded = 0,
    detailsViewStatusMinimized = 1,
    detailsViewStatusClosed = 2
} DetailsViewStatus;

typedef enum{
    MapModeTrending = 0,
    MapModeFollowedLocations = 1,
} MapMode;


@interface MapController : UIViewController <GMSMapViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    GMSMapView *googleMapView;
    NSMutableArray *listOfLocations;
    NSMutableArray *listOfEventsinSelectedLocation;
    UITableView *usersTableView;
    UIView *viewDetailsContainer;
    UIView *loaderView;
    UIButton *trendingLocationsButton;
    UIButton *followedLocationsButton;
    UIButton *mapViewTypeToggleButton;
    Timeline *selectedTimeline;
    Event *selectedEvent;
    Event *tempActiveEventForAction;
    Location *selectedLocation;
    BOOL isMoreData;
    int currentPage;
    BOOL loadingInProgress;
    BOOL loadingTimelinesInProgress;
    BOOL loadingLocationsInProgress;
    DetailsViewStatus detailViewStatus;
    MapMode currentMode;
    BOOL userMovedMap;
    UIView *actionOverlayCalloutView;
}

//@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet GMSMapView *googleMapView;
@property (nonatomic, retain) NSMutableArray *listOfLocations;
@property (nonatomic, retain) IBOutlet UITableView *usersTableView;
@property (nonatomic, retain) IBOutlet UIButton *followedLocationsButton;
@property (nonatomic, retain) IBOutlet UIButton *trendingLocationsButton;
@property (nonatomic, retain) IBOutlet UIButton *mapViewTypeToggleButton;
@property (nonatomic, retain) Location *selectedLocation;
@property (nonatomic, retain) NSMutableArray *listOfEventsinSelectedLocation;
@property (nonatomic, retain) IBOutlet UIView *viewDetailsContainer;
@property (nonatomic, retain) IBOutlet UIView *actionOverlayCalloutView;
@property (nonatomic,strong) IBOutlet UIView *loaderView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailsViewBottomConstraint;

- (IBAction)trendingAction:(id)sender;
- (IBAction)followedAction:(id)sender;
- (IBAction)toggleMapViewtypeAction:(id)sender;
- (IBAction)unwindMapEventMentionsSegue:(UIStoryboardSegue*)segue;

@end
