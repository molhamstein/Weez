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


@interface LocationPickerController : UIViewController <GMSMapViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *listOfLocationsAndEvents;
    NSMutableArray *listOfPlaces;
}

@property (nonatomic, retain) IBOutlet GMSMapView *googleMapView;
@property (nonatomic, retain) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) IBOutlet UIView *viewDetailsContainer;
@property (nonatomic, retain) IBOutlet UIView *loaderView;
@property (nonatomic, retain) IBOutlet UILabel *lblTagsTitle;
@property (nonatomic, retain) IBOutlet UIView *tagsContainer;
@property (nonatomic, retain) IBOutlet UICollectionView *tagsCollectionView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *detailsViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tagsViewHeightConstraint;

@property (nonatomic, retain) Location* selectedLocation;
@property (nonatomic, retain) Event* selectedEvent;
@property (nonatomic, retain) NSMutableArray *listOfTags;
@property (nonatomic) CLLocationCoordinate2D customSelectedCoord;

@property (nonatomic) CLLocationCoordinate2D initialMapPosition;
-(void)prepareControllerWithlimitToOnlyNearLocations:(BOOL)limitToNearLocations initialMapPos:(CLLocationCoordinate2D)initPos enableTags:(BOOL)tagsEnable allowSelectingCoordinates:(BOOL)allowCoordinates parentViewController:(UIViewController*)parent;
@end
