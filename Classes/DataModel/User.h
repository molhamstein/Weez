//
//  User.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface User : NSObject <NSCoding, NSCopying>
{
    NSString *objectId;
    NSString *username;
    NSString *facebookId;
    NSString *sessionToken;
    NSString *email;
    NSString *bio;
    NSString *displayName;
    NSString *profilePic;
    NSString *phoneNumber;
    NSMutableArray *followersList;
    NSMutableArray *followingsList;
    NSMutableArray *sentFollowingRequestsList;// follow request sent by me to private accounts
    NSMutableArray *recievedFollowingRequestsList;
    NSMutableArray *followedLocationsList;
    NSMutableArray *followedEventsList;
    int imageDuration;
    int mentionsCount;
    int groupsCount;
    int locationsCount;
    int eventsCount;
    UserGrantType grantType;
    AppChatPrivacyLevel chatPrivacyLevel;
    BOOL isAdmin;
    BOOL isPrivate;
    BOOL deviceRegistered;
    BOOL notificationsFlagBoosts;
    BOOL notificationsFlagMentions;
    BOOL notificationsFlagMessages;
    BOOL notificationsFlagFollowers;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *facebookId;
@property (nonatomic,retain) NSString *sessionToken;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *bio;
@property (nonatomic,retain) NSString *displayName;
@property (nonatomic,retain) NSString *profilePic;
@property (nonatomic,retain) NSString *phoneNumber;
@property (nonatomic,retain) NSMutableArray *followersList;
@property (nonatomic,retain) NSMutableArray *followingsList;
@property (nonatomic,retain) NSMutableArray *sentFollowingRequestsList;
@property (nonatomic,retain) NSMutableArray *recievedFollowingRequestsList;
@property (nonatomic, retain) NSMutableArray *followedLocationsList;
@property (nonatomic, retain) NSMutableArray *followedEventsList;
@property (nonatomic) int imageDuration;
@property (nonatomic) int mentionsCount;
@property (nonatomic) int groupsCount;
@property (nonatomic) int locationsCount;
@property (nonatomic) int eventsCount;
@property (nonatomic) UserGrantType grantType;
@property (nonatomic) AppChatPrivacyLevel chatPrivacyLevel;
@property (nonatomic) BOOL isAdmin;
@property (nonatomic) BOOL deviceRegistered;
@property (nonatomic) BOOL notificationsFlagBoosts;
@property (nonatomic) BOOL notificationsFlagMentions;
@property (nonatomic) BOOL notificationsFlagMessages;
@property (nonatomic) BOOL notificationsFlagFollowers;
@property (nonatomic) BOOL isPrivate;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (void)updateUserInfo:(NSDictionary*)jsonObject;
- (NSString*)getProfilePicLink;
- (void)followFriend:(NSString*)friendId;
- (void)followLocation:(NSString*)locationId;
- (BOOL)isFollowingLocation:(NSString *)locationId;
- (void)followEvent:(NSString*)eventId;
- (BOOL)isFollowingEvent:(NSString *)eventId;
- (BOOL)isNotificationOn;

@end
