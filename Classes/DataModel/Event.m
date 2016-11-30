//
//  Event.m
//  Weez
//
//  Created by Molham on 8/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Event.h"
#import "ConnectionManager.h"

@implementation Event

@synthesize objectId;
@synthesize name;
@synthesize image;
@synthesize startDate;
@synthesize endDate;
@synthesize location;
@synthesize cover;
@synthesize eventFollowers;
@synthesize totalMediaDuration;

#pragma mark -
#pragma mark User Object
// Init with message decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    objectId = [decoder decodeObjectForKey:@"objectId"];
    name = [decoder decodeObjectForKey:@"name"];
    image = [decoder decodeObjectForKey:@"image"];
    cover =[decoder decodeObjectForKey:@"coverImage"];
    location = [decoder decodeObjectForKey:@"location"];
    eventFollowers = [decoder decodeIntForKey:@"eventFollowers"];
    totalMediaDuration= [decoder decodeFloatForKey:@"totalMediaDuration"];
    return self;
}

// Encode with User encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:image forKey:@"image"];
    [encoder encodeObject:cover forKey:@"coverImage"];
    [encoder encodeObject:startDate forKey:@"startDate"];
    [encoder encodeObject:endDate forKey:@"endDate"];
    [encoder encodeObject:location forKey:@"location"];
    [encoder encodeInt:eventFollowers forKey:@"eventFollowers"];
    [encoder encodeFloat:totalMediaDuration forKey:@"totalMediaDuration"];
}

// Fill User object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    name = (NSString*)[jsonObject objectForKey:@"name"];
    image = (NSString*)[jsonObject objectForKey:@"image"];
    cover = (NSString*) [jsonObject objectForKey:@"coverImage"];
    eventFollowers = [[jsonObject objectForKey:@"followersCount"] intValue];
    totalMediaDuration = [[jsonObject objectForKey:@"totalMediaDuration"] floatValue];
    // date formater
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    //start date
    NSString *dateStr = [jsonObject objectForKey:@"startDate"];
    startDate = [dateFormatter dateFromString:dateStr];
    // convert the date from GMT to local time
    startDate = [startDate dateByAddingTimeInterval:timeZoneSeconds];
    
    //start date
    dateStr = [jsonObject objectForKey:@"endDate"];
    endDate = [dateFormatter dateFromString:dateStr];
    // convert the date from GMT to local time
    endDate = [endDate dateByAddingTimeInterval:timeZoneSeconds];
    
    location = [[Location alloc] init];
    location.objectId = @"";
    // we have to fill the location if exist
    if ([jsonObject objectForKey:@"location"] != [NSNull null] && !([[jsonObject objectForKey:@"location"] isKindOfClass:[NSString class]]) )
        [location fillWithJSON:[jsonObject objectForKey:@"location"]];
    
}

// Event is bookmarked
- (BOOL)isFollowing
{
    // this location exists in user fav locations list
    if ([[[ConnectionManager sharedManager] userObject].followedEventsList containsObject:objectId])
        return YES;
    return NO;
}

@end
