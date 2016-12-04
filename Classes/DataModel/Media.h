//
//  Media.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Location.h"
#import "Event.h"

@interface Media : NSObject <NSCoding>
{
    NSString *objectId;
    NSString *mediaLink;
    NSString *thumbLink;
    NSString *largeWideThumb;
    int duration;
    int boostCount;
    MediaType mediaType;
    Location *location;
    Event *event;
    BOOL isMediaBoosted;
    BOOL isMediaViewed;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) NSString *mediaLink;
@property (nonatomic,retain) NSString *thumbLink;
@property (nonatomic) int duration;
@property (nonatomic) int boostCount;
@property (nonatomic) MediaType mediaType;
@property (nonatomic,retain) Location *location;
@property (nonatomic,retain) Event *event;
@property (nonatomic, retain) NSString *largeWideThumb;
@property (nonatomic) BOOL isMediaBoosted;
@property (nonatomic) BOOL isMediaViewed;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (NSURL*)fetchLocalURL;

@end
