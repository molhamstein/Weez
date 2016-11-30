//
//  LocatoinAnnotation.m
//  Weez
//
//  Created by Molham on 7/12/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "LocatoinAnnotation.h"

@implementation LocatoinAnnotation



- (id)initWithTitle:(NSString *)newTitle subtitle:(NSString *)newSubtitle restaurant:(Location *)newLocationObject location:(CLLocationCoordinate2D)location {
    
    self = [super init];
    if (self) {
        self.title = newTitle;
        self.coordinate = location;
        self.locationObject = newLocationObject;
    }
    
    return self;
}

- (MKAnnotationView *)annotationView {
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:restaurantAnnotationIdentifier];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
    
}

@end
