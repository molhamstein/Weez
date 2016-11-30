//
//  LocatoinAnnotation.h
//  Weez
//
//  Created by Molham on 7/12/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Location.h"

static NSString *restaurantAnnotationIdentifier = @"locationAnnotationIdentifier";

@interface LocatoinAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Location *locationObject;


- (id)initWithTitle:(NSString *)newTitle subtitle:(NSString *)newSubtitle restaurant:(Location *)newLocationObject location:(CLLocationCoordinate2D)location;

- (MKAnnotationView *)annotationView;
@end