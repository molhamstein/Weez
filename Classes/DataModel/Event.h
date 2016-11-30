//
//  Event.h
//  Weez
//
//  Created by Molham on 8/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface Event : NSObject
{
    NSString *objectId;
    NSString *name;
    NSString *image;
    NSString *cover;
    NSDate *startDate;
    NSDate *endDate;
    Location *location;
    int eventFollowers;
    float totalMediaDuration;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *image;
@property (nonatomic, retain) NSString *cover;
@property (nonatomic,retain) NSDate *startDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic,retain) Location *location;
@property (nonatomic) int eventFollowers;
@property (nonatomic) float totalMediaDuration;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (BOOL)isFollowing;
@end
