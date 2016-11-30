//
//  UserProfile.m
//  Weez
//
//  Created by Molham on 7/19/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "UserProfile.h"
#import "Location.h"
#import "Event.h"

@implementation UserProfile

@synthesize boosts;
//@synthesize lastViewedMedia;
@synthesize lastViewedIndex;
@synthesize followersList;
@synthesize followingsList;
@synthesize sentFollowingRequestsList;
@synthesize recievedFollowingRequestsList;
@synthesize followedEventsList;
@synthesize followedLocationsList;
@synthesize bio;
@synthesize checkedInEventsList;
@synthesize checkedInLocationsList;

- (id)initWithCoder:(NSCoder*)decoder{
    
    self = [super initWithCoder:decoder];
    if (!self)
    {
        return nil;
    }
    bio = [decoder decodeObjectForKey:@"bio"];
    followersList = [decoder decodeObjectForKey:@"followersList"];
    followingsList = [decoder decodeObjectForKey:@"followingsList"];
    sentFollowingRequestsList = [decoder decodeObjectForKey:@"sentFollowingRequestsList"];
    recievedFollowingRequestsList = [decoder decodeObjectForKey:@"recievedFollowingRequestsList"];
    boosts = [decoder decodeObjectForKey:@"boosts"];
    lastViewedMedia = [decoder decodeObjectForKey:@"lastViewedMedia"];
    lastViewedIndex = [decoder decodeIntForKey:@"lastViewedIndex"];
    followedLocationsList = [decoder decodeObjectForKey:@"favoriteLocations"];
    followedEventsList = [decoder decodeObjectForKey:@"favoriteEvents"];
    checkedInLocationsList = [decoder decodeObjectForKey:@"myLocations"];
    checkedInEventsList = [decoder decodeObjectForKey:@"myEvents"];

    return self;
}

// Encode with encoder
- (void)encodeWithCoder:(NSCoder*)encoder{
    
    [super encodeWithCoder:encoder];
    [encoder encodeObject:bio forKey:@"bio"];
    [encoder encodeObject:followersList forKey:@"followersList"];
    [encoder encodeObject:followingsList forKey:@"followingsList"];
    [encoder encodeObject:sentFollowingRequestsList forKey:@"sentFollowingRequestsList"];
    [encoder encodeObject:recievedFollowingRequestsList forKey:@"recievedFollowingRequestsList"];
    [encoder encodeObject:boosts forKey:@"boosts"];
    [encoder encodeObject:lastViewedMedia forKey:@"lastViewedMedia"];
    [encoder encodeInt:lastViewedIndex forKey:@"lastViewedIndex"];
    [encoder encodeObject:followedLocationsList forKey:@"favoriteLocations"];
    [encoder encodeObject:followedEventsList forKey:@"favoriteEvents"];
    [encoder encodeObject:checkedInLocationsList forKey:@"myLocations"];
    [encoder encodeObject:checkedInEventsList forKey:@"myEvents"];
}

// Fill Profile object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject{
    
    [super fillWithJSON:jsonObject];
    bio = (NSString*)[jsonObject objectForKey:@"bio"];
    followersList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followers"]];
    followingsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followings"]];
    recievedFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followRequests"]];
    sentFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"pendingFollowRequests"]];
    
    //boosts
    NSMutableArray *resultList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"boosts"]];
    boosts = [[NSMutableArray alloc] init];
    // loop all sections
    for (NSMutableDictionary *resultObj in resultList)
    {
        Timeline *timelineObj = [[Timeline alloc] init];
        [timelineObj fillWithJSON:resultObj];
        [boosts addObject:timelineObj];
    }
    
    // followed locations
    NSMutableArray *favLocationsJSONList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteLocations"]];
    followedLocationsList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *resultObj in favLocationsJSONList)
    {
        Location *timelineObj = [[Location alloc] init];
        [timelineObj fillWithJSON:resultObj];
        [followedLocationsList addObject:timelineObj];
    }
    
    // followed events
    NSMutableArray *favEventsJSONList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteEvents"]];
    followedEventsList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *resultObj in favEventsJSONList)
    {
        Event *timelineObj = [[Event alloc] init];
        [timelineObj fillWithJSON:resultObj];
        [followedEventsList addObject:timelineObj];
    }
    
    // followed locations
    NSMutableArray *checkedLocationsJSONList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"myLocations"]];
    checkedInLocationsList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *resultObj in checkedLocationsJSONList)
    {
        Location *timelineObj = [[Location alloc] init];
        [timelineObj fillWithJSON:resultObj];
        [checkedInLocationsList addObject:timelineObj];
    }
    
    // followed events
    NSMutableArray *checkedEventsJSONList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"myEvents"]];
    checkedInEventsList = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *resultObj in checkedEventsJSONList)
    {
        Event *timelineObj = [[Event alloc] init];
        [timelineObj fillWithJSON:resultObj];
        [checkedInEventsList addObject:timelineObj];
    }
        
    // last viewed media
    lastViewedMedia = [[Media alloc] init];
    lastViewedMedia.objectId = @"";
    // we have to fill the location if exist
    if ([jsonObject objectForKey:@"lastViewedMedia"] != [NSNull null])
        [lastViewedMedia fillWithJSON:[jsonObject objectForKey:@"lastViewedMedia"]];
    
    lastViewedIndex = [[jsonObject objectForKey:@"lastViewedIndex"] intValue];

}

//-(NSMutableArray*) getCombinedArrayOfFavEventAndLocations{
//    NSMutableArray * combinedArray = [NSMutableArr]
//}

@end
