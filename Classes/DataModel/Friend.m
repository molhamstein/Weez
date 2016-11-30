//
//  Friend.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Friend.h"
#import "ConnectionManager.h"

@implementation Friend

@synthesize objectId;
@synthesize username;
@synthesize facebookId;
@synthesize email;
@synthesize displayName;
@synthesize profilePic;
@synthesize phoneNumber;
@synthesize followersCount;
@synthesize isPrivate;
@synthesize grantType;

#pragma mark -
#pragma mark Friend Object
// Init with Friend decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode friend values
    // objectId - username - facebookId - email - displayName - profilePic - phoneNumber - grantType
    objectId = [decoder decodeObjectForKey:@"objectId"];
    username = [decoder decodeObjectForKey:@"username"];
    facebookId = [decoder decodeObjectForKey:@"facebookId"];
    email = [decoder decodeObjectForKey:@"email"];
    displayName = [decoder decodeObjectForKey:@"displayName"];
    profilePic = [decoder decodeObjectForKey:@"profilePic"];
    phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
    followersCount = [decoder decodeIntForKey:@"followersCount"];
    isPrivate = [decoder decodeBoolForKey:@"isPrivate"];
    grantType = [decoder decodeIntForKey:@"grantType"];
    return self;
}

// Encode with Friend encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode friend values
    // objectId - username - facebookId - email - displayName - profilePic - phoneNumber - grantType
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:username forKey:@"username"];
    [encoder encodeObject:facebookId forKey:@"facebookId"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:displayName forKey:@"displayName"];
    [encoder encodeObject:profilePic forKey:@"profilePic"];
    [encoder encodeInt:followersCount forKey:@"followersCount"];
    [encoder encodeBool:isPrivate forKey:@"isPrivate"];
    [encoder encodeInt:grantType forKey:@"grantType"];
}

// Fill Friend object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // friend keys
    // id - username - facebookId - email - name - profilePic - phoneNumber
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    username = (NSString*)[jsonObject objectForKey:@"username"];
    facebookId = (NSString*)[NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"facebookId"]];
    email = @"";
    if ([jsonObject objectForKey:@"email"] != nil)
        email = (NSString*)[jsonObject objectForKey:@"email"];
    displayName = (NSString*)[jsonObject objectForKey:@"name"];
    profilePic = (NSString*)[jsonObject objectForKey:@"profilePic"];
    phoneNumber = @"";
    if ([jsonObject objectForKey:@"phoneNumber"] != nil)
        phoneNumber = (NSString*)[jsonObject objectForKey:@"phoneNumber"];
    
    NSMutableArray *followersList = [[NSMutableArray alloc] initWithArray:[jsonObject objectForKey:@"followers"]];
    if(followersList != NULL){
        followersCount = (int) followersList.count;
    }else{
        followersCount = 0;
    }
    isPrivate = [[jsonObject objectForKey:@"private"] boolValue];
    // set grant type
    grantType = kUserGrantTypePassword;
    if ([facebookId length] > 1 && [facebookId intValue] > 0)
        grantType = kUserGrantTypeFacebook;
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



- (BOOL)amAskingForFollow
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].sentFollowingRequestsList containsObject:objectId])
        return YES;
    return NO;
}

// Friend is follower for me
- (BOOL)isFollower
{
    // this friend exists in user followers list
    if ([[[ConnectionManager sharedManager] userObject].followersList containsObject:objectId])
        return YES;
    return NO;
}

- (BOOL)isAskingForFollow
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].recievedFollowingRequestsList containsObject:objectId])
        return YES;
    return NO;
}

// Friend is following me
- (BOOL)isFollowing
{
    // this friend exists in user following list
    if ([[[ConnectionManager sharedManager] userObject].followingsList containsObject:objectId])
        return YES;
    return NO;
}

- (FOLLOWING_STATE) getFollowingState
{
    if([self amAskingForFollow])
        return REQUESTED;
    if ([self isFollowing])
        return FOLLOWING;
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
