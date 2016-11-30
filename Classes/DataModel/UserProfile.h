//
//  UserProfile.h
//  Weez
//
//  Created by Molham on 7/19/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "Media.h"
#import "Constants.h"

@interface UserProfile : Timeline
{
    NSMutableArray *followersList;
    NSMutableArray *followingsList;
    NSMutableArray *sentFollowingRequestsList;// follow request sent by me to private accounts
    NSMutableArray *recievedFollowingRequestsList;
    // profile specific data
    NSMutableArray *boosts;
    Media *lastViewedMedia;
    int lastViewedIndex;
    NSString *bio;
    NSMutableArray *followedLocationsList;
    NSMutableArray *followedEventsList;
    NSMutableArray *checkedInLocationsList;
    NSMutableArray *checkedInEventsList;

}

@property (nonatomic,retain) NSMutableArray *boosts;
//@property (nonatomic,retain) Media *lastViewedMedia;
@property int lastViewedIndex;
@property (nonatomic,retain) NSString *bio;
@property (nonatomic,retain) NSMutableArray *followersList;
@property (nonatomic,retain) NSMutableArray *followingsList;
@property (nonatomic,retain) NSMutableArray *sentFollowingRequestsList;
@property (nonatomic,retain) NSMutableArray *recievedFollowingRequestsList;
@property (nonatomic,retain) NSMutableArray *followedLocationsList;
@property (nonatomic,retain) NSMutableArray *followedEventsList;
@property (nonatomic,retain) NSMutableArray *checkedInLocationsList;
@property (nonatomic,retain) NSMutableArray *checkedInEventsList;



@end
