//
//  Location.h
//  Weez
//
//  Created by Molham on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <CoreLocation/CLLocation.h>

@interface Location : NSObject <NSCoding>
{
    NSString *objectId;
    NSString *name;
    NSString *image;
    NSString *cover;
    NSString *address;
    NSString *city;
    NSString *country;
    NSString *countryCode;
    float longitude;
    float latitude;
    float totalMediaDuration;
    int mediaCount;
    int timelinesCount;
    int locationFollowers;
    NSMutableArray *timelines;
    NSMutableArray *events;
    LocationStatus status;
    
    /// undefined places are the places corrdninate placess picked from
    /// google maps "places with no name and are only defined by there coords"
    BOOL isUnDefinedPlace;
    /// private locations are somehow equavelent to undeFinedPlaces exempt they are registered on the system
    BOOL isPrivateLocation;
}

@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *cover;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *countryCode;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) float totalMediaDuration;
@property (nonatomic) int mediaCount;
@property (nonatomic) int timelinesCount;
@property (nonatomic) int locationFollowers;
@property (nonatomic, retain) NSMutableArray *timelines;
@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic) LocationStatus status;

- (instancetype) initUndefinedWithCoords:(CLLocationCoordinate2D) coords;

/*! used by the clint side to flag the places defined by only coordinnates and does not have a name
this flag is local and does not have an equavelent on the API */
@property BOOL isUnDefinedPlace;

/*! indicates that the location is not public and does not have any timelines,
 private locations are coordinate based locations ad does not have names */
@property BOOL isPrivateLocation;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (BOOL)isFollowing;

@end