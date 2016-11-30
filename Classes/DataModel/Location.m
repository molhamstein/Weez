//
//  Location.h
//  Weez
//
//  Created by Molham on 6/12/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Location.h"
#import "Constants.h"
#import "ConnectionManager.h"
#import "Timeline.h"
#import "Event.h"

@implementation Location

@synthesize objectId;
@synthesize name;
@synthesize image;
@synthesize cover;
@synthesize address;
@synthesize city;
@synthesize country;
@synthesize countryCode;
@synthesize longitude;
@synthesize latitude;
@synthesize mediaCount;
@synthesize timelinesCount;
@synthesize locationFollowers;
@synthesize timelines;
@synthesize events;
@synthesize status;
@synthesize isUnDefinedPlace;
@synthesize isPrivateLocation;
@synthesize totalMediaDuration;

#pragma mark -
#pragma mark Location Object
// Init with Location decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode Location values
    objectId = [decoder decodeObjectForKey:@"objectId"];
    name = [decoder decodeObjectForKey:@"name"];
    image = [decoder decodeObjectForKey:@"image"];
    cover = [decoder decodeObjectForKey:@"cover"];
    address = [decoder decodeObjectForKey:@"address"];
    city = [decoder decodeObjectForKey:@"city"];
    country = [decoder decodeObjectForKey:@"country"];
    countryCode = [decoder decodeObjectForKey:@"countryCode"];
    longitude = [decoder decodeFloatForKey:@"longitude"];
    latitude = [decoder decodeFloatForKey:@"latitude"];
    mediaCount = [decoder decodeIntForKey:@"mediaCount"];
    timelinesCount = [decoder decodeIntForKey:@"timelinesCount"];
    locationFollowers = [decoder decodeIntForKey:@"locationFollowers"];
    timelines = [decoder decodeObjectForKey:@"timelines"];
    events = [decoder decodeObjectForKey:@"events"];
    status = [decoder decodeIntForKey:@"status"];
    isUnDefinedPlace = [decoder decodeBoolForKey:@"isUnDefinedPlace"];
    isPrivateLocation = [decoder decodeBoolForKey:@"isPrivateLocation"];
    totalMediaDuration = [decoder decodeFloatForKey:@"totalMediaDuration"];
    return self;
}

// Encode with Location encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode Location values
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:image forKey:@"image"];
    [encoder encodeObject:cover forKey:@"cover"];
    [encoder encodeObject:address forKey:@"address"];
    [encoder encodeObject:city forKey:@"city"];
    [encoder encodeObject:country forKey:@"country"];
    [encoder encodeObject:countryCode forKey:@"countryCode"];
    [encoder encodeFloat:longitude forKey:@"longitude"];
    [encoder encodeFloat:latitude forKey:@"latitude"];
    [encoder encodeInt:mediaCount forKey:@"mediaCount"];
    [encoder encodeInt:timelinesCount forKey:@"timelinesCount"];
    [encoder encodeInt:locationFollowers forKey:@"locationFollowers"];
    [encoder encodeObject:timelines forKey:@"timelines"];
    [encoder encodeObject:events forKey:@"events"];
    [encoder encodeInt:status forKey:@"status"];
    [encoder encodeBool:isUnDefinedPlace forKey:@"isUnDefinedPlace"];
    [encoder encodeBool:isPrivateLocation forKey:@"isPrivateLocation"];
    [encoder encodeFloat:totalMediaDuration forKey:@"isPrivateLocation"];
}

// Fill Location object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // Location keys
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    name = (NSString*)[jsonObject objectForKey:@"name"];
    image = (NSString*)[jsonObject objectForKey:@"image"];
    cover = (NSString*)[jsonObject objectForKey:@"coverImage"];
    address = (NSString*)[jsonObject objectForKey:@"address"];
    city = (NSString*)[jsonObject objectForKey:@"city"];
    country = (NSString*)[jsonObject objectForKey:@"country"];
    countryCode = (NSString*)[jsonObject objectForKey:@"countryCode"];
    longitude = [[jsonObject objectForKey:@"long"] floatValue];
    latitude = [[jsonObject objectForKey:@"lat"] floatValue];
    mediaCount = [[jsonObject objectForKey:@"mediaCount"] intValue];
    timelinesCount = [[jsonObject objectForKey:@"timelinesCount"] intValue];
    locationFollowers = [[jsonObject objectForKey:@"followersCount"] intValue];
    status = [[jsonObject objectForKey:@"status"] intValue];
    isPrivateLocation = [[jsonObject objectForKey:@"private"] intValue];
    totalMediaDuration = [[jsonObject objectForKey:@"totalMediaDuration"] floatValue];
    timelines  = [[NSMutableArray alloc] init];
    //users
    if([jsonObject objectForKey:@"users"] != nil && [[jsonObject objectForKey:@"users"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *resultList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"users"]];
        // loop all sections
        for (NSMutableDictionary *resultObj in resultList)
        {
            Timeline *timelineObj = [[Timeline alloc] init];
            [timelineObj fillWithJSON:resultObj];
            [timelines addObject:timelineObj];
        }
    }
    // events
    events  = [[NSMutableArray alloc] init];
    if([jsonObject objectForKey:@"events"] != nil && [[jsonObject objectForKey:@"events"] isKindOfClass:[NSArray class]])
    {
        NSMutableArray *jsonEventsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"events"]];
        
        // loop all sections
        for (NSMutableDictionary *resultObj in jsonEventsList)
        {
            Event *eventObj = [[Event alloc] init];
            [eventObj fillWithJSON:resultObj];
            [events addObject:eventObj];
        }
    }
}


// location is bookmarked
- (BOOL)isFollowing
{
    // this location exists in user fav locations list
    if ([[[ConnectionManager sharedManager] userObject].followedLocationsList containsObject:objectId])
        return YES;
    return NO;
}


@end