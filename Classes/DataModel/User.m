//
//  User.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "User.h"
#import "ConnectionManager.h"

@implementation User

@synthesize objectId;
@synthesize username;
@synthesize facebookId;
@synthesize sessionToken;
@synthesize email;
@synthesize bio;
@synthesize displayName;
@synthesize profilePic;
@synthesize phoneNumber;
@synthesize followersList;
@synthesize followingsList;
@synthesize sentFollowingRequestsList;
@synthesize recievedFollowingRequestsList;
@synthesize followedLocationsList;
@synthesize imageDuration;
@synthesize mentionsCount;
@synthesize groupsCount;
@synthesize locationsCount;
@synthesize eventsCount;
@synthesize grantType;
@synthesize chatPrivacyLevel;
@synthesize isAdmin;
@synthesize isPrivate;
@synthesize deviceRegistered;
@synthesize notificationsFlagBoosts;
@synthesize notificationsFlagMentions;
@synthesize notificationsFlagMessages;
@synthesize notificationsFlagFollowers;
@synthesize followedEventsList;

#pragma mark -
#pragma mark User Object
// Init with User decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode user values
    // objectId - username - facebookId - sessionToken - email - displayName - profilePic - phoneNumber - followersList - followingsList
    // imageDuration - mentionsCount - groupsCount - locationsCount - grantType - isAdmin - deviceRegistered - notificationsFlagBoosts
    // notificationsFlagMentions - notificationsFlagMessages - notificationsFlagFollowers
    objectId = [decoder decodeObjectForKey:@"objectId"];
    username = [decoder decodeObjectForKey:@"username"];
    facebookId = [decoder decodeObjectForKey:@"facebookId"];
    sessionToken = [decoder decodeObjectForKey:@"sessionToken"];
    email = [decoder decodeObjectForKey:@"email"];
    bio = [decoder decodeObjectForKey:@"bio"];
    displayName = [decoder decodeObjectForKey:@"displayName"];
    profilePic = [decoder decodeObjectForKey:@"profilePic"];
    phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
    followersList = [decoder decodeObjectForKey:@"followersList"];
    followingsList = [decoder decodeObjectForKey:@"followingsList"];
    sentFollowingRequestsList = [decoder decodeObjectForKey:@"sentFollowingRequestsList"];
    recievedFollowingRequestsList = [decoder decodeObjectForKey:@"recievedFollowingRequestsList"];
    followedLocationsList = [decoder decodeObjectForKey:@"favoriteLocations"];
    followedEventsList = [decoder decodeObjectForKey:@"favoriteEvents"];
    imageDuration = [decoder decodeIntForKey:@"imageDuration"];
    mentionsCount = [decoder decodeIntForKey:@"mentionsCount"];
    groupsCount = [decoder decodeIntForKey:@"groupsCount"];
    locationsCount = [decoder decodeIntForKey:@"locationsCount"];
    eventsCount = [decoder decodeIntForKey:@"eventsCount"];
    grantType = [decoder decodeIntForKey:@"grantType"];
    chatPrivacyLevel = [decoder decodeIntForKey:@"chatSettings"];
    isAdmin = [decoder decodeBoolForKey:@"isAdmin"];
    isPrivate = [decoder decodeBoolForKey:@"isPrivate"];
    deviceRegistered = [decoder decodeBoolForKey:@"deviceRegistered"];
    notificationsFlagBoosts = [decoder decodeBoolForKey:@"notificationsFlagBoosts"];
    notificationsFlagMentions = [decoder decodeBoolForKey:@"notificationsFlagMentions"];
    notificationsFlagMessages = [decoder decodeBoolForKey:@"notificationsFlagMessages"];
    notificationsFlagFollowers = [decoder decodeBoolForKey:@"notificationsFlagFollowers"];
    return self;
}

// Encode with User encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode user values
    // objectId - username - facebookId - sessionToken - email - displayName - profilePic - phoneNumber - followersList - followingsList
    // imageDuration - mentionsCount - groupsCount - locationsCount - grantType - isAdmin - deviceRegistered - notificationsFlagBoosts
    // notificationsFlagMentions - notificationsFlagMessages - notificationsFlagFollowers
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:facebookId forKey:@"facebookId"];
    [encoder encodeObject:sessionToken forKey:@"sessionToken"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:bio forKey:@"bio"];
    [encoder encodeObject:displayName forKey:@"displayName"];
    [encoder encodeObject:profilePic forKey:@"profilePic"];
    [encoder encodeObject:phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:followersList forKey:@"followersList"];
    [encoder encodeObject:followingsList forKey:@"followingsList"];
    [encoder encodeObject:sentFollowingRequestsList forKey:@"sentFollowingRequestsList"];
    [encoder encodeObject:recievedFollowingRequestsList forKey:@"recievedFollowingRequestsList"];
    [encoder encodeObject:followedLocationsList forKey:@"favoriteLocations"];
    [encoder encodeObject:followedEventsList forKey:@"favoriteEvents"];
    [encoder encodeInt:imageDuration forKey:@"imageDuration"];
    [encoder encodeInt:mentionsCount forKey:@"mentionsCount"];
    [encoder encodeInt:groupsCount forKey:@"groupsCount"];
    [encoder encodeInt:locationsCount forKey:@"locationsCount"];
    [encoder encodeInt:eventsCount forKey:@"eventsCount"];
    [encoder encodeInt:grantType forKey:@"grantType"];
    [encoder encodeInt:chatPrivacyLevel forKey:@"chatSettings"];
    [encoder encodeBool:isAdmin forKey:@"isAdmin"];
    [encoder encodeBool:isPrivate forKey:@"isPrivate"];
    [encoder encodeBool:deviceRegistered forKey:@"deviceRegistered"];
    [encoder encodeBool:notificationsFlagBoosts forKey:@"notificationsFlagBoosts"];
    [encoder encodeBool:notificationsFlagMentions forKey:@"notificationsFlagMentions"];
    [encoder encodeBool:notificationsFlagMessages forKey:@"notificationsFlagMessages"];
    [encoder encodeBool:notificationsFlagFollowers forKey:@"notificationsFlagFollowers"];
}

// Fill User object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // player keys
    // id - username - facebookId - token - email - name - profilePic - phoneNumber - followers - followings - imageDuration
    // mentionsCount - groupsCount - myLocationsCount - isAdmin - boost - mention - newMessage - newFollower
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    username = (NSString*)[jsonObject objectForKey:@"username"];
    facebookId = (NSString*)[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"facebookId"]];
    sessionToken = (NSString*)[jsonObject objectForKey:@"token"];
    email = @"";
    if ([jsonObject objectForKey:@"email"] != nil)
        email = (NSString*)[jsonObject objectForKey:@"email"];
    bio = (NSString*)[jsonObject objectForKey:@"bio"];
    displayName = (NSString*)[jsonObject objectForKey:@"name"];
    profilePic = (NSString*)[jsonObject objectForKey:@"profilePic"];
    phoneNumber = @"";
    if ([jsonObject objectForKey:@"phoneNumber"] != nil)
        phoneNumber = (NSString*)[jsonObject objectForKey:@"phoneNumber"];
    followersList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followers"]];
    followingsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followings"]];
    recievedFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followRequests"]];
    sentFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"pendingFollowRequests"]];
    followedLocationsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteLocations"]];
    followedEventsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteEvents"]];
    imageDuration = [[jsonObject objectForKey:@"imageDuration"] intValue];
    mentionsCount = [[jsonObject objectForKey:@"mentionsCount"] intValue];
    groupsCount = [[jsonObject objectForKey:@"groupsCount"] intValue];
    locationsCount = [[jsonObject objectForKey:@"myLocationsCount"] intValue];
    eventsCount = [[jsonObject objectForKey:@"myEventsCount"] intValue];
    // set grant type
    grantType = kUserGrantTypePassword;
    if ([facebookId length] > 1 && [facebookId intValue] > 0)
        grantType = kUserGrantTypeFacebook;
    
    chatPrivacyLevel = kChatPrivacyLevelAll;
    if([jsonObject objectForKey:@"chatSettings"])
        chatPrivacyLevel = [[jsonObject objectForKey:@"chatSettings"] intValue];
    
    isAdmin = [[jsonObject objectForKey:@"isAdmin"] boolValue];
    isPrivate = [[jsonObject objectForKey:@"private"] boolValue];
    // notifications settings
    notificationsFlagBoosts = YES;
    notificationsFlagMentions = YES;
    notificationsFlagMessages = YES;
    notificationsFlagFollowers = YES;
    if ([jsonObject objectForKey:@"notifications"] != nil)
    {
        NSDictionary *notificationSettingsJsn = [jsonObject objectForKey:@"notifications"];
        notificationsFlagBoosts = [[notificationSettingsJsn objectForKey:@"boost"] boolValue];
        notificationsFlagMentions = [[notificationSettingsJsn objectForKey:@"mention"] boolValue];
        notificationsFlagMessages = [[notificationSettingsJsn objectForKey:@"newMessage"] boolValue];
        notificationsFlagFollowers = [[notificationSettingsJsn objectForKey:@"newFollower"] boolValue];
    }
    // local params
    deviceRegistered = NO;
}

// Fill User object form json object
- (void)updateUserInfo:(NSDictionary*)jsonObject
{
    // user keys
    // id - username - facebookId - token - email - name - profilePic - phoneNumber - followers - followings - imageDuration
    // mentionsCount - groupsCount - boost - mention - newMessage - newFollower
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    username = (NSString*)[jsonObject objectForKey:@"username"];
    facebookId = (NSString*)[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"facebookId"]];
    sessionToken = (NSString*)[jsonObject objectForKey:@"token"];
    email = @"";
    if ([jsonObject objectForKey:@"email"] != nil)
        email = (NSString*)[jsonObject objectForKey:@"email"];
    bio = (NSString*)[jsonObject objectForKey:@"bio"];
    displayName = (NSString*)[jsonObject objectForKey:@"name"];
    profilePic = (NSString*)[jsonObject objectForKey:@"profilePic"];
    phoneNumber = @"";
    if ([jsonObject objectForKey:@"phoneNumber"] != nil)
        phoneNumber = (NSString*)[jsonObject objectForKey:@"phoneNumber"];
    followersList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followers"]];
    followingsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followings"]];
    recievedFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followRequests"]];
    sentFollowingRequestsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"pendingFollowRequests"]];
    followedLocationsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteLocations"]];
    followedEventsList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"favoriteEvents"]];
    imageDuration = [[jsonObject objectForKey:@"imageDuration"] intValue];
    mentionsCount = [[jsonObject objectForKey:@"mentionsCount"] intValue];
    groupsCount = [[jsonObject objectForKey:@"groupsCount"] intValue];
    locationsCount = [[jsonObject objectForKey:@"myLocationsCount"] intValue];
    eventsCount = [[jsonObject objectForKey:@"myEventsCount"] intValue];
    // set grant type
    grantType = kUserGrantTypePassword;
    if ([facebookId length] > 1 && [facebookId intValue] > 0)
        grantType = kUserGrantTypeFacebook;
    
    chatPrivacyLevel = kChatPrivacyLevelAll;
    if([jsonObject objectForKey:@"chatSettings"])
        chatPrivacyLevel = [[jsonObject objectForKey:@"chatSettings"] intValue];
    
    isAdmin = [[jsonObject objectForKey:@"isAdmin"] boolValue];
    isPrivate = [[jsonObject objectForKey:@"private"] boolValue];
    // notifications settings
    if ([jsonObject objectForKey:@"notifications"] != nil)
    {
        NSDictionary *notificationSettingsJsn = [jsonObject objectForKey:@"notifications"];
        notificationsFlagBoosts = [[notificationSettingsJsn objectForKey:@"boost"] boolValue];
        notificationsFlagMentions = [[notificationSettingsJsn objectForKey:@"mention"] boolValue];
        notificationsFlagMessages = [[notificationSettingsJsn objectForKey:@"newMessage"] boolValue];
        notificationsFlagFollowers = [[notificationSettingsJsn objectForKey:@"newFollower"] boolValue];
    }
}

// Get player profile picture link
- (NSString*)getProfilePicLink
{
    // profile pic exists
    if ((profilePic != nil) && ([profilePic length] > 0))
    {
        return profilePic;
    }
    else// profile pic not exist
    {
        // grant type facebook
        if (grantType == kUserGrantTypeFacebook)
            return [NSString stringWithFormat:FACEBOOK_IMAGE_LINK, facebookId];
        else// default profile pic
            return PROFILE_DEFAULT_PIC_LINK;
    }
}

// Follow/Unfollow friend
- (void)followFriend:(NSString*)friendId
{
    // unfollow case
    if ([followingsList containsObject:friendId])
        [followingsList removeObject:friendId];
    else// follow case
        [followingsList addObject:friendId];
}

// Request Follow/ Cancel follow request of private friend
- (void)requestfollowFriend:(NSString*)friendId
{
    // unfollow case
    if ([sentFollowingRequestsList containsObject:friendId])
        [sentFollowingRequestsList removeObject:friendId];
    else// follow case
        [sentFollowingRequestsList addObject:friendId];
}

- (void)followFriend:(NSString*)friendId withPrivateProfile:(BOOL)hasPrivateProfile
{
    if(!hasPrivateProfile)
        [self followFriend:friendId];
    else
        [self requestfollowFriend:friendId];
}

// Follow/Unfollow location
- (void)followLocation:(NSString*)locationId
{
    // unfollow case
    if ([followedLocationsList containsObject:locationId])
        [followedLocationsList removeObject:locationId];
    else// follow case
        [followedLocationsList addObject:locationId];
}

// check if user is following this location
- (BOOL)isFollowingLocation:(NSString *) locationId{
    // this friend exists in user following list
    if ([followedLocationsList containsObject:locationId])
        return YES;
    return NO;
}

// Follow/Unfollow event
- (void)followEvent:(NSString*)eventId
{
    // unfollow case
    if ([followedEventsList containsObject:eventId])
        [followedEventsList removeObject:eventId];
    else// follow case
        [followedEventsList addObject:eventId];
}

// check if user is following this event
- (BOOL)isFollowingEvent:(NSString *) eventId{
    // this event exists in user following list
    if ([followedEventsList containsObject:eventId])
        return YES;
    return NO;
}

// Is notification on
- (BOOL)isNotificationOn
{
    return notificationsFlagBoosts || notificationsFlagMentions || notificationsFlagMessages || notificationsFlagFollowers;
}

#pragma mark -
#pragma mark User Object
// Copy user object
- (id)copyWithZone:(NSZone*)zone
{
    User *another = [[User allocWithZone: zone] init];
    another.objectId = [objectId copyWithZone:zone];
    another.username = [username copyWithZone:zone];
    another.facebookId = [facebookId copyWithZone:zone];
    another.sessionToken = [sessionToken copyWithZone:zone];
    another.email = [email copyWithZone:zone];
    another.bio = [bio copyWithZone:zone];
    another.displayName = [displayName copyWithZone:zone];
    another.profilePic = [profilePic copyWithZone:zone];
    another.phoneNumber = [phoneNumber copyWithZone:zone];
    another.followersList = [followersList copyWithZone:zone];
    another.followingsList = [followingsList copyWithZone:zone];
    another.recievedFollowingRequestsList = [recievedFollowingRequestsList copyWithZone:zone];
    another.sentFollowingRequestsList = [sentFollowingRequestsList copyWithZone:zone];
    another.followedLocationsList = [followedLocationsList copyWithZone:zone];
    another.followedEventsList = [followedEventsList copyWithZone:zone];
    another.imageDuration = imageDuration;
    another.mentionsCount = mentionsCount;
    another.groupsCount = groupsCount;
    another.locationsCount = locationsCount;
    another.grantType = grantType;
    another.isAdmin = isAdmin;
    another.isPrivate = isPrivate;
    another.deviceRegistered = deviceRegistered;
    another.notificationsFlagBoosts = notificationsFlagBoosts;
    another.notificationsFlagMentions = notificationsFlagMentions;
    another.notificationsFlagMessages = notificationsFlagMessages;
    another.notificationsFlagFollowers = notificationsFlagFollowers;
    return another;
}

@end
