//
//  TimelineMapCell.h
//  Weez
//
//  Created by Dania on 10/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@import GoogleMaps;

@interface TimelineMapCell : UITableViewCell
{
    GMSMapView *googleMapView;
    UIButton *mapOverlayButton;
    //data
    NSMutableArray *listOfLocationsTimelines;
}


@property(nonatomic, retain) IBOutlet GMSMapView *googleMapView;
@property(nonatomic, retain) IBOutlet UIButton *mapPlayAllButton;

- (void) initMap;
- (void) reloadMapAnnotaions:(NSMutableArray *)data;

@end