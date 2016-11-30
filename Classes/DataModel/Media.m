//
//  Media.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Media.h"
#import "AppManager.h"

@implementation Media

@synthesize objectId;
@synthesize mediaLink;
@synthesize thumbLink;
@synthesize duration;
@synthesize mediaType;
@synthesize location;
@synthesize event;
@synthesize largeWideThumb;
@synthesize boostCount;
@synthesize isMediaBoosted;

#pragma mark -
#pragma mark Media Object
// Init with Media decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode media values
    // objectId - mediaLink - thumbLink - duration - mediaType - location
    objectId = [decoder decodeObjectForKey:@"objectId"];
    mediaLink = [decoder decodeObjectForKey:@"mediaLink"];
    thumbLink = [decoder decodeObjectForKey:@"thumbLink"];
    duration = [decoder decodeIntForKey:@"duration"];
    mediaType = [decoder decodeIntForKey:@"mediaType"];
    location = [decoder decodeObjectForKey:@"location"];
    event = [decoder decodeObjectForKey:@"event"];
    largeWideThumb = [decoder decodeObjectForKey:@"largeWideThumb"];
    boostCount = [decoder decodeIntForKey:@"boostCount"];
    isMediaBoosted = [decoder decodeBoolForKey:@"isBoosted"];
    return self;
}

// Encode with Media encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode media values
    // objectId - mediaLink - thumbLink - duration - mediaType - location
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:mediaLink forKey:@"mediaLink"];
    [encoder encodeObject:thumbLink forKey:@"thumbLink"];
    [encoder encodeInt:duration forKey:@"duration"];
    [encoder encodeInt:mediaType forKey:@"mediaType"];
    [encoder encodeObject:location forKey:@"location"];
    [encoder encodeObject:event forKey:@"event"];
    [encoder encodeObject:largeWideThumb forKey:@"largeWideThumb"];
    [encoder encodeInt:boostCount forKey:@"boostCount"];
    [encoder encodeBool:isMediaBoosted forKey:@"isBoosted"];
}

// Fill Media object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // media keys
    // id - url - smallPortraitThumb - mediaType - duration - date
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    mediaLink = (NSString*)[jsonObject objectForKey:@"url"];
    thumbLink = (NSString*)[jsonObject objectForKey:@"smallPortraitThumb"];
    largeWideThumb = (NSString*)[jsonObject objectForKey:@"largeWideThumb"];
    mediaType = [[jsonObject objectForKey:@"mediaType"] intValue];
    duration = [[jsonObject objectForKey:@"duration"] intValue];
    boostCount = [[jsonObject objectForKey:@"boostCount"] intValue];
    isMediaBoosted = [[jsonObject objectForKey:@"isBoosted"] boolValue];
    location = [[Location alloc] init];
    location.objectId = @"";
    // we have to fill the location if exist
    if ([jsonObject objectForKey:@"location"] != [NSNull null])
        [location fillWithJSON:[jsonObject objectForKey:@"location"]];
    event = [[Event alloc] init];
    event.objectId = @"";
    if ([jsonObject objectForKey:@"event"] != [NSNull null])
        [event fillWithJSON:[jsonObject objectForKey:@"event"]];
}

// Media video local url if downloaded locally
- (NSURL*)fetchLocalURL
{
    return [[AppManager sharedManager] fetchLocalVideoURL:mediaLink.lastPathComponent];
}

@end
