//
//  TimelineMapCell.m
//  Weez
//
//  Created by Dania on 10/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineMapCell.h"
#import "AppManager.h"

@implementation TimelineMapCell

@synthesize googleMapView;
@synthesize mapPlayAllButton;

-(void) initMap{
    googleMapView.myLocationEnabled = YES;
    googleMapView.settings.zoomGestures = NO;
    googleMapView.settings.tiltGestures = NO;
    googleMapView.settings.rotateGestures = NO;
    googleMapView.settings.scrollGestures = NO;    
}

// Reload map annotations
- (void) reloadMapAnnotaions:(NSMutableArray *)data{
    listOfLocationsTimelines = data;
    
    float minLat = 1000.0;
    float minLon = 1000.0;
    float maxLat = -1000.0;
    float maxLon = -1000.0;
    if([listOfLocationsTimelines count] > 0)
        [googleMapView clear];
    // loop overall providers
    for (int i = 0; i < [listOfLocationsTimelines count]; i++){
        
        Location *providerObj = [listOfLocationsTimelines objectAtIndex:i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(providerObj.latitude, providerObj.longitude);
        marker.title = nil;
        marker.snippet = nil;
        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
        marker.icon = [UIImage imageNamed:@"mapAnnotation"];
        marker.userData = providerObj;
        marker.map = googleMapView;
        
        // set min and max lat/lon
        if (providerObj.latitude > maxLat)
            maxLat = providerObj.latitude;
        if (providerObj.latitude < minLat)
            minLat = providerObj.latitude;
        if (providerObj.longitude > maxLon)
            maxLon = providerObj.longitude;
        if (providerObj.longitude < minLon)
            minLon = providerObj.longitude;
    }
    // position camera
    if ([listOfLocationsTimelines count] > 0){
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:[AppManager sharedManager].currenttUserLocation.coordinate zoom:12];
        [googleMapView setCamera:camera];
        
        //center map to fit all retrieved markers
        //CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(minLat,minLon);
        //CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(maxLat,maxLon);
        //GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:southWest coordinate:northEast];
        //[googleMapView moveCamera:[GMSCameraUpdate fitBounds:bounds]];
    }
}

@end
