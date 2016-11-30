//
//  Timeline.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface Timeline : NSObject <NSCoding>
{
    NSString *userId;
    NSString *username;
    NSString *displayName;
    NSString *email;
    NSString *profilePic;
    NSString *smallThumb;
    NSString *largeThumb;
    NSString *portraitThumb;
    NSDate *lastMediaDate;
    int mediaDuration;
    int totalViewed;
    int viewedPercentage;
    int locationNo;
    TimelineType timelineType;
    // mention & boost
    NSString *actorId;
    NSString *actorUsername;
    NSString *mediaId;
    // group & chat
    NSString *actorMessage;
    MediaType actorLastMediaType;
    BOOL canChat;
    BOOL isPrivate;
}

@property (nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *displayName;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *profilePic;
@property (nonatomic,retain) NSString *smallThumb;
@property (nonatomic,retain) NSString *largeThumb;
@property (nonatomic,retain) NSString *portraitThumb;
@property (nonatomic,retain) NSDate *lastMediaDate;
@property (nonatomic) int mediaDuration;
@property (nonatomic) int totalViewed;
@property (nonatomic) int viewedPercentage;
@property (nonatomic) int locationNo;
@property (nonatomic) TimelineType timelineType;
@property (nonatomic) BOOL canChat;
@property (nonatomic) BOOL isPrivate;
// mention & boost
@property (nonatomic,retain) NSString *actorId;
@property (nonatomic,retain) NSString *actorUsername;
@property (nonatomic,retain) NSString *mediaId;
// group & chat
@property (nonatomic,retain) NSString *actorMessage;
@property (nonatomic) MediaType actorLastMediaType;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (NSString*)getUpdatedDateString:(BOOL)isShort;
- (BOOL)isFollowing;
- (BOOL)amAskingForFollow;
- (BOOL)isFollower;
- (FOLLOWING_STATE) getFollowingState;
- (FOLLOWER_STATE) getFollowerState;

@end
