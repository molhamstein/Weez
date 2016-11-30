//
//  Friend.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface Friend : NSObject <NSCoding>
{
    NSString *objectId;
    NSString *username;
    NSString *facebookId;
    NSString *email;
    NSString *displayName;
    NSString *profilePic;
    NSString *phoneNumber;
    int followersCount;
    UserGrantType grantType;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) NSString *username;
@property (nonatomic,retain) NSString *facebookId;
@property (nonatomic,retain) NSString *email;
@property (nonatomic,retain) NSString *displayName;
@property (nonatomic,retain) NSString *profilePic;
@property (nonatomic,retain) NSString *phoneNumber;
@property (nonatomic) int followersCount;
@property (nonatomic) UserGrantType grantType;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (NSString*)getProfilePicLink;
- (BOOL)isFollowing;
- (BOOL)isFollower;

@end
