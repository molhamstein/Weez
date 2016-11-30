//
//  MapController.m
//  Weez
//
//  Created by Molham on 6/14/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "CoordinatesDetailsController.h"
#import "AppManager.h"

@implementation CoordinatesDetailsController

//@synthesize mapView;
@synthesize googleMapView;


- (void)viewDidLoad{
    [super viewDidLoad];
    
    // configure view
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self reloadMapAnnotations];
    
    //center map on marker
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:CLLocationCoordinate2DMake(_lat, _lng) zoom:13];
    [googleMapView setCamera:camera];
}


- (void)configView{
    
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_MAP_TITLE"];
    
    // init map
    googleMapView.delegate = self;
}

- (void)setCoordinatesLat:(float) lat andLong:(float)lng{
    self.lat = lat;
    self.lng = lng;
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Map
// Reload map annotations
- (void)reloadMapAnnotations{
    [googleMapView clear];
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(_lat, _lng);
    marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
    marker.snippet = nil;
    marker.icon = [UIImage imageNamed:@"mapAnnotation"];
    marker.map = googleMapView;
}

//- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
//    return [self infoWindwForMarker:marker];
//}


- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"mapView.selectedMarker"]) {
//        if (!self.googleMapView.selectedMarker) {
//            [self.actionOverlayCalloutView removeFromSuperview];
//        }
//    }
//}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker{
}

@end
