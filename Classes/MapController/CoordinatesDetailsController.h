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
@import GoogleMaps;


@interface CoordinatesDetailsController : UIViewController <GMSMapViewDelegate>
{
    //MKMapView *mapView;
    GMSMapView *googleMapView;
}

@property(strong, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (nonatomic) float lat;
@property (nonatomic) float lng;
- (void)setCoordinatesLat:(float) lat andLong:(float)lng;

@end
