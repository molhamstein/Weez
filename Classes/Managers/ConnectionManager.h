//
//  ViewController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "User.h"
#import "Timeline.h"
#import "UserProfile.h"
#import "Group.h"
#import "Event.h"
#import <CoreLocation/CoreLocation.h>

@interface ConnectionManager : NSObject
{
    User *userObject;
    NSMutableArray *timelinesList;
    NSMutableArray *messagesList;
    NSMutableArray *topMessagesList;
    NSMutableArray *timelinesLocationsList;
    NSMutableArray *nearbyLocations;
    NSMutableArray *favLocationsList;
    NSMutableArray *imageDurations;
    NSMutableArray *reportTypes;
    NSString *deviceIdentifier;
    NSString *log;
}

@property (nonatomic, retain) User* userObject;
@property (nonatomic, retain) NSMutableArray *timelinesList;
@property (nonatomic, retain) NSMutableArray *messagesList;
@property (nonatomic, retain) NSMutableArray *topMessagesList;
@property (nonatomic, retain) NSMutableArray *timelinesLocationsList;
@property (nonatomic, retain) NSMutableArray *favLocationsList;
@property (nonatomic, retain) NSMutableArray *imageDurations;
@property (nonatomic, retain) NSMutableArray *reportTypes;
@property (nonatomic, retain) NSMutableArray *nearbyLocations;
@property (nonatomic, retain) NSString *deviceIdentifier;

+ (ConnectionManager*)sharedManager;
// User
- (BOOL)isUserLoggedIn;
- (void)userLogIn:(void (^)())loginSuccess failure:(void (^)(NSError *error))loginFailure;
- (void)userLogout;
- (void)updateUserInfo:(User*)newUser withImage:(UIImage*)pickedImage success:(void (^)())updateUserInfoSuccess failure:(void (^)(NSError *error, int errorCode))updateUserInfoFailure;
- (void)getCurrentUser:(void (^)())getCurrentUserSuccess failure:(void (^)(NSError *error))getCurrentUserFailure;
- (void)getGlobalList:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getCurrentUserProfile:(void (^)(UserProfile*, Media*, int))getCurrentUserSuccess failure:(void (^)(NSError *error))getCurrentUserFailure;
- (void)getUserProfile:(NSString*) userId onSucces:(void (^)(UserProfile*, Media*, int))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getUserNotifications: (void (^)(NSMutableArray*))onSuccess failure:(void (^)(NSError *error))onFailure;
// Timelines
- (void)getTimelinesList:(int)page lattitude:(float)lat longitude:(float)lon success:(void (^)(BOOL withPages))getTimelinesListSuccess failure:(void (^)(NSError *error))getTimelinesListFailure;
- (void)getLocationTimelines:(int)page LocationId:(NSString*)locationId lastId:(NSString*)lastId success:(void (^)(NSString *locationId, BOOL withPages, NSMutableArray* friends,NSMutableArray* all))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getTagTimelines:(int)page TagId:(NSString*)tagId success:(void (^)(NSString *tagId, BOOL withPages, NSMutableArray*))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)searchForTimeline:(NSString*)keyword success:(void (^)(NSMutableArray *timelineList))searchForTimelineSuccess failure:(void (^)(NSError *error))searchForTimelineFailure;
- (void)getTimelineMedia:(Timeline*)timeline success:(void (^)(NSMutableArray *mediaList, int startIndex))getTimelineMediaSuccess failure:(void (^)(NSError *error))getTimelineMediaFailure;
- (void)uploadMedia:(MediaType)mediaType withLocation:(NSString*)locationId withEventId:(NSString*)eventId withVideo:(NSURL*)videoURL withImage:(UIImage*)pickedImage withRecipients:(NSMutableArray*)recipients
        withGroups :(NSMutableArray*)groups withPublic:(BOOL)isPublic withHashtags:(NSMutableArray*)hashtags success:(void (^)())uploadMediaSuccess failure:(void (^)(NSError *error, int errorCode))uploadMediaFailure;
- (void)uploadMedia:(MediaType)mediaType withCustomLocation:(Location*)location withEventId:(NSString*)eventId withVideo:(NSURL*)videoURL withImage:(UIImage*)pickedImage withRecipients:(NSMutableArray*)recipients
        withGroups :(NSMutableArray*)groups withPublic:(BOOL)isPublic withHashtags:(NSMutableArray*)hashtags success:(void (^)())uploadMediaSuccess failure:(void (^)(NSError *error, int errorCode))uploadMediaFailure;
- (void)watchMedia:(NSString*)userId withMediaId:(NSString*)mediaId success:(void (^)())watchMediaSuccess failure:(void (^)(NSError *error))watchMediaFailure;
- (void)boostMedia:(NSString*)userId withMediaId:(NSString*)mediaId success:(void (^)())boostMediaSuccess failure:(void (^)(NSError *error))boostMediaFailure;
- (void)mentionMedia:(NSString*)userId withMediaId:(NSString*)mediaId withMentionList:(NSMutableArray*)mentionList success:(void (^)())mentionMediaSuccess failure:(void (^)(NSError *error))mentionMediaFailure;
// Map
- (void)getFavoriteLocations:(void (^)(NSMutableArray *favLocations))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getTrendingLocationsListNear:(float)lat long:(float)lon withRadius:(double)radius success:(void (^)(NSMutableArray *locations))onSuccess failure:(void (^)(NSError *error))onFailure;
// search
- (void)search:(NSString*)keyword for:(SearchMode) searchMode success:(void (^)(NSMutableArray *usersList, SearchMode searchMode))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)searchForTop: (void (^)(NSMutableDictionary *topFeeds))onSuccess failure:(void (^)(NSError *error))onFailure;
// Friends
- (void)searchForUser:(NSString*)username success:(void (^)(NSMutableArray *usersList))searchForUserSuccess failure:(void (^)(NSError *error))searchForUserFailure;
- (void)followUser:(NSString*)userId success:(void (^)())followUserSuccess failure:(void (^)(NSError *error))followUserFailure;
- (void)acceptFollowRequest:(NSString*)userId success:(void (^)())acceptSuccess failure:(void (^)(NSError *error))acceptFailure;
- (void)rejectFollowRequest:(NSString*)userId success:(void (^)())rejectSuccess failure:(void (^)(NSError *error))rejectFailure;
- (void)getFollowingList:(FollowType)followType rankedBy:(TimelineType)rankBy success:(void (^)(NSMutableArray *usersList))getFollowingListSuccess failure:(void (^)(NSError *error))getFollowingListFailure;
- (void)getMentionList:(void (^)(NSMutableArray *mentionList))getMentionListSuccess failure:(void (^)(NSError *error))getMentionListFailure;
- (void)getRecipientsListRankedBy:(NSString*)rankBy onSuccess:(void (^)(NSMutableArray *usersList, NSMutableArray *groupsList))getRecipientsListSuccess failure:(void (^)(NSError *error))getRecipientsListFailure;
- (void)reportUser:(NSString*)userId reportType:(int)reportType success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
// Events
- (void)followEvent:(NSString*)eventId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)updateEvent:(Event*)newEvent withLocationId:(NSString *) locationId withImage:(UIImage*)pickedImage withCover:(UIImage*)coverImage success:(void (^)())onSuccess failure:(void (^)(NSError *error, int errorCode))onFailure;
- (void)getMyEventsList:(void (^)(NSMutableArray *locationsList))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getEventTimelines:(int)page eventId:(NSString*)eventId lastId:(NSString*)lastId success:(void (^)(NSString *eventId, BOOL withPages, NSMutableArray* newFriends, NSMutableArray* newTimelines))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getTimelineMediaInEvent:(NSString*)userId eventId:(NSString*)eventId success:(void (^)(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)mentionToEvent:(Event*)event recepients:recepients success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
// Location
- (void)followLocation:(NSString*)locationId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getNextTimelineInLocation:(NSString*)locationId orEvent:(NSString*)eventId next:(BOOL)next currentlyWatchedUserId:(NSString*) currentUserId dateOfCurrentTimeline:(NSString*) dateOfCurrentTimeline success:(void (^)(Timeline*,NSMutableArray*, int, BOOL))onSuccess failure:(void (^)(NSDictionary *error))onFailure;
- (void)getTimelineMediaInLocation:(NSString*)userId locationId:(NSString*)locationId success:(void (^)(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev))getTimelineMediaSuccess failure:(void (^)(NSError *error))getTimelineMediaFailure;
- (void)getLocationsList:(BOOL)myLocations success:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure;
- (void)getLocationsRelatedTo:(NSString *)userId success:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure;
- (void)updateLocation:(Location*)location withImage:(UIImage*)pickedImage withCover:(UIImage*)coverImage success:(void (^)())updateLocationSuccess failure:(void (^)(NSError *error, int errorCode))updateLocationFailure;
- (void)deleteMedia:(NSString*)mediaId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure;
// Group chat
- (void)getchatList:(int)page success:(void (^)(BOOL withPages))getChatListSuccess failure:(void (^)(NSError *error))getChatListFailure;
- (void)getGroupList:(void (^)(NSMutableArray *groupList))getGroupListSuccess failure:(void (^)(NSError *error))getGroupListFailure;
- (void)updateGroup:(Group*)group withImage:(UIImage*)pickedImage success:(void (^)(Group *updatedGroup))updateGroupSuccess failure:(void (^)(NSError *error, int errorCode))updateGroupFailure;
- (void)leaveGroup:(NSString*)groupId success:(void (^)())leaveGroupSuccess failure:(void (^)(NSError *error))leaveGroupFailure;
- (void)getGroup:(Group*)group success:(void (^)(Group *group))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)getChat:(NSString*)userId success:(void (^)(Group *group))onSuccess failure:(void (^)(NSError *error))onFailure;
- (void)sendChatMessage:(NSString *) messsage ToGroup:(Group*)group mediaType:(MediaType) mediaType media:(id) media withFileURL:(NSURL *)fileURL orLocationMessageAt:(CLLocationCoordinate2D) coordinates withLocationId:(NSString*)locationId orCustomLocation:(Location*)customLocation asReplyToMessage:(NSString*)originalMsgId inOriginalGroup:(NSString*)originalGrroupId sharedTimelineId:(NSString*)sharedTimelineId sharedLocationId:(NSString*)sharedLocationId sharedEventId:(NSString*)sharedEventId success:(void (^)())onSuccess failure:(void (^)(NSError *error, NSString *errorMsg))onFailure;
// Devices
- (void)registerDeviceForNotification:(NSString*)deviceID success:(void (^)())registerDeviceSuccess failure:(void (^)(NSError *error))registerDeviceFailure;
// Sign up register user
- (void)signupRegisterUser:(NSDictionary*)registerInfo success:(void (^)(int resultFlag))signupRegisterUserSuccess failure:(void (^)(NSError *error))signupRegisterUserFailure;
- (void)signinLogin:(NSString*)email andPassword:(NSString*)password success:(void (^)())signupLoginSuccess failure:(void (^)(NSError *error, NSString* errorMsg))signupLoginFailure;
- (void)resetPassword:(NSString*)userEmail withNumber:(NSString*)userNumber success:(void (^)())resetPasswordSuccess failure:(void (^)(NSError *error, int errorCode))resetPasswordFailure;
- (void)changePassword:(NSString*)oldPassword withNewPass:(NSString*)newPassword success:(void (^)())changePasswordSuccess failure:(void (^)(NSError *error, int errorCode))changePasswordFailure;
- (void)getLocationsAndEventsListSuccess:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList, NSMutableArray *placesList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure;
// Video
- (void)downloadVideoFromURL:(NSString*)videoLink progress:(void (^)(CGFloat progress))downloadVideoFromURLProgress success:(void (^)(NSURL *filePath))downloadVideoFromURLSuccess failure:(void (^)(NSError *error))downloadVideoFromURLFailure;

- (void)submitLog:(NSString*)logMsg success:(void (^)())onSuccess;
- (void)flushLog;
@end
