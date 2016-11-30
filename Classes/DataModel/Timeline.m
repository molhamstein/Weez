//
//  Timeline.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Timeline.h"
#import "Constants.h"
#import "ConnectionManager.h"
#import "AppManager.h"

@implementation Timeline

@synthesize userId;
@synthesize username;
@synthesize displayName;
@synthesize email;
@synthesize profilePic;
@synthesize smallThumb;
@synthesize largeThumb;
@synthesize portraitThumb;
@synthesize lastMediaDate;
@synthesize mediaDuration;
@synthesize totalViewed;
@synthesize viewedPercentage;
@synthesize locationNo;
@synthesize timelineType;
// mention & boost
@synthesize actorId;
@synthesize actorUsername;
@synthesize mediaId;
// group & chat
@synthesize actorMessage;
@synthesize actorLastMediaType;
@synthesize canChat;
@synthesize isPrivate;

#pragma mark -
#pragma mark Timeline Object
// Init with Timeline decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode timeline values
    // userId - username - displayName - email - profilePic - smallThumb - largeThumb - portraitThumb - lastMediaDate - mediaDuration
    // totalViewed - viewedPercentage - locationNo - timelineType - actorId - actorUsername - mediaId - actorMessage - actorLastMediaType
    userId = [decoder decodeObjectForKey:@"userId"];
    username = [decoder decodeObjectForKey:@"username"];
    displayName = [decoder decodeObjectForKey:@"displayName"];
    email = [decoder decodeObjectForKey:@"email"];
    profilePic = [decoder decodeObjectForKey:@"profilePic"];
    smallThumb = [decoder decodeObjectForKey:@"smallThumb"];
    largeThumb = [decoder decodeObjectForKey:@"largeThumb"];
    portraitThumb = [decoder decodeObjectForKey:@"portraitThumb"];
    lastMediaDate = [decoder decodeObjectForKey:@"lastMediaDate"];
    mediaDuration = [decoder decodeIntForKey:@"mediaDuration"];
    totalViewed = [decoder decodeIntForKey:@"totalViewed"];
    viewedPercentage = [decoder decodeIntForKey:@"viewedPercentage"];
    locationNo = [decoder decodeIntForKey:@"locationNo"];
    timelineType = [decoder decodeIntForKey:@"timelineType"];
    // mention & boost
    actorId = [decoder decodeObjectForKey:@"actorId"];
    actorUsername = [decoder decodeObjectForKey:@"actorUsername"];
    mediaId = [decoder decodeObjectForKey:@"mediaId"];
    // group & chat
    actorMessage = [decoder decodeObjectForKey:@"actorMessage"];
    actorLastMediaType = [decoder decodeIntForKey:@"actorLastMediaType"];
    canChat = [decoder decodeBoolForKey:@"canChat"];
    isPrivate = [decoder decodeBoolForKey:@"isPrivate"];
    return self;
}

// Encode with Timeline encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode timeline values
    // userId - username - displayName - email - profilePic - smallThumb - largeThumb - portraitThumb - lastMediaDate - mediaDuration
    // totalViewed - viewedPercentage - locationNo - timelineType - actorId - actorUsername - mediaId - actorMessage - actorLastMediaType
    // groupMembers - groupMessages - isGroupAdmin
    [encoder encodeObject:userId forKey:@"userId"];
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:displayName forKey:@"displayName"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:profilePic forKey:@"profilePic"];
    [encoder encodeObject:smallThumb forKey:@"smallThumb"];
    [encoder encodeObject:largeThumb forKey:@"largeThumb"];
    [encoder encodeObject:portraitThumb forKey:@"portraitThumb"];
    [encoder encodeObject:lastMediaDate forKey:@"lastMediaDate"];
    [encoder encodeInt:mediaDuration forKey:@"mediaDuration"];
    [encoder encodeInt:totalViewed forKey:@"totalViewed"];
    [encoder encodeInt:viewedPercentage forKey:@"viewedPercentage"];
    [encoder encodeInt:locationNo forKey:@"locationNo"];
    [encoder encodeInt:timelineType forKey:@"timelineType"];
    // mention & boost
    [encoder encodeObject:actorId forKey:@"actorId"];
    [encoder encodeObject:actorUsername forKey:@"actorUsername"];
    [encoder encodeObject:mediaId forKey:@"mediaId"];
    // group & chat
    [encoder encodeObject:actorMessage forKey:@"actorMessage"];
    [encoder encodeInt:actorLastMediaType forKey:@"actorLastMediaType"];
    [encoder encodeBool:canChat forKey:@"canChat"];
    [encoder encodeBool:isPrivate forKey:@"isPrivate"];
}

// Fill Timeline object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // timeline keys
    // id - username - email - displayName - profilePic - smallWideThumb - largeWideThumb - largePortraitThumb - totalMediaDuration
    // durationViewed - viewedPercentage - locationsCount - lastMediaDate - type - actorId - actorUsername - mediaId - actorMessage - actorLastMediaType
    userId = (NSString*)[jsonObject objectForKey:@"id"];
    username = (NSString*)[jsonObject objectForKey:@"username"];
    displayName = (NSString*)[jsonObject objectForKey:@"name"];
    email = (NSString*)[jsonObject objectForKey:@"email"];
    profilePic = (NSString*)[jsonObject objectForKey:@"profilePic"];
    smallThumb = (NSString*)[jsonObject objectForKey:@"smallWideThumb"];
    largeThumb = (NSString*)[jsonObject objectForKey:@"largeWideThumb"];
    portraitThumb = (NSString*)[jsonObject objectForKey:@"largePortraitThumb"];
    mediaDuration = [[jsonObject objectForKey:@"totalMediaDuration"] intValue];
    totalViewed = [[jsonObject objectForKey:@"durationViewed"] intValue];
    viewedPercentage = [[jsonObject objectForKey:@"viewedPercentage"] intValue];
    locationNo = [[jsonObject objectForKey:@"locationsCount"] intValue];
    canChat = [[jsonObject objectForKey:@"canChat"] boolValue];
    isPrivate = [[jsonObject objectForKey:@"private"] boolValue];
    // set last updated date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    NSString *dateStr = [jsonObject objectForKey:@"lastMediaDate"];
    lastMediaDate = [dateFormatter dateFromString:dateStr];
    // check actor information (Mention & Boost)
    timelineType = kTimelineTypeUser;
    if ([jsonObject objectForKey:@"type"] != nil)
        timelineType = [[jsonObject objectForKey:@"type"] intValue];
    actorId = @"";
    if ([jsonObject objectForKey:@"actorId"] != nil)
        actorId = (NSString*)[jsonObject objectForKey:@"actorId"];
    actorUsername = @"";
    if ([jsonObject objectForKey:@"actorUsername"] != nil)
        actorUsername = [jsonObject objectForKey:@"actorUsername"];
    mediaId = @"";
    if ([jsonObject objectForKey:@"mediaId"] != nil)
        mediaId = [jsonObject objectForKey:@"mediaId"];
    // group & chat
    actorMessage = @"";
    if ([jsonObject objectForKey:@"actorMessage"] != nil)
        actorMessage = (NSString*)[jsonObject objectForKey:@"actorMessage"];
    actorLastMediaType = kMediaTypeText;
    if ([jsonObject objectForKey:@"actorLastMediaType"] != nil)
        actorLastMediaType = [[jsonObject objectForKey:@"actorLastMediaType"] intValue];
}

// Get updated date string
- (NSString*)getUpdatedDateString:(BOOL)isShort
{
    if (lastMediaDate == nil)
        return @"";
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    //[formatter setDateFormat:TIMELINE_SHORT_DATE_FORMAT];
//    [formatter setLocale:[NSLocale currentLocale]];
//    [formatter setDoesRelativeDateFormatting:YES];
//    [formatter setDateStyle: NSDateFormatterShortStyle];
//    // check if today date
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:lastMediaDate];
//    NSDate *otherDate = [cal dateFromComponents:components];
//    // set time formater
////    if ([today isEqualToDate:otherDate])
////        [formatter setDateFormat:TIMELINE_DISPLAY_TIME_FORMAT];
//    NSString *str = [formatter stringFromDate:lastMediaDate];
    
    // past alert date
    NSDate *currentDate = [NSDate date];
    NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:lastMediaDate];
    NSTimeInterval difference = [currentDate timeIntervalSinceDate:localDateTime];
    return [[AppManager sharedManager] timeIntervalToStringWithInterval:difference];
    
}

// Friend is following me
- (BOOL)isFollowing
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].followingsList containsObject:userId])
        return YES;
    return NO;
}

- (BOOL)isAskingForFollow
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].recievedFollowingRequestsList containsObject:userId])
        return YES;
    return NO;
}

// Friend is follower for me
- (BOOL)isFollower
{
    // this friend exists in user followers list
    if ([[[ConnectionManager sharedManager] userObject].followersList containsObject:userId])
        return YES;
    return NO;
}

- (BOOL)amAskingForFollow
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].sentFollowingRequestsList containsObject:userId])
        return YES;
    return NO;
}

- (FOLLOWING_STATE) getFollowingState
{
    if ([self isFollowing])
        return FOLLOWING;
    if([self amAskingForFollow])
        return REQUESTED;
    return NOT_FOLLOWING;
}

- (FOLLOWER_STATE) getFollowerState
{
    if([self isFollower])
        return FOLLOWER;
    if([self isAskingForFollow])
        return PENDING;
    return NOT_FOLLOWER;
}
@end
