//
//  ViewController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "ConnectionManager.h"
#import "AFHTTPSessionManager.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "SocialManager.h"
#import "AppManager.h"
#import "AppDelegate.h"
#import "Timeline.h"
#import "Friend.h"
#import "Media.h"
#import "Location.h"
#import "Tag.h"
#import "ReportType.h"
#import "AppNotification.h"

ConnectionManager* m_pgAsyncDataManager = nil;

@implementation ConnectionManager

@synthesize userObject;
@synthesize timelinesList;
@synthesize messagesList;
@synthesize topMessagesList;
@synthesize timelinesLocationsList;
@synthesize favLocationsList;
@synthesize nearbyLocations;
@synthesize deviceIdentifier;
@synthesize imageDurations;
@synthesize reportTypes;

#pragma mark -
#pragma mark Singilton Init Methods
// Shared connection singleton.
+ (ConnectionManager*)sharedManager
{
    if(m_pgAsyncDataManager == nil)
        m_pgAsyncDataManager = [[ConnectionManager alloc] init];
    return m_pgAsyncDataManager;
}

// Alloc shared API singleton.
+ (id)alloc
{
	@synchronized( self )
    {
		NSAssert(m_pgAsyncDataManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

// Init the manager
- (id)init
{
	if ( self = [super init] )
    {
        // load user settings dictionary
        userObject = [[AppManager sharedManager] cachedUserData];
        timelinesList = [[NSMutableArray alloc] init];
        messagesList = [[NSMutableArray alloc] init];
        topMessagesList = [[NSMutableArray alloc] init];
        timelinesLocationsList = [[NSMutableArray alloc] init];
        favLocationsList = [[NSMutableArray alloc] init];
        nearbyLocations = [[NSMutableArray alloc] init];
        
        // report types
        reportTypes = (NSMutableArray*) [[AppManager sharedManager] cachedDicotionaryData:CACH_USER_FOLDER cachFile:CACH_REPORT_FILE];
        
        // image durations
        imageDurations = (NSMutableArray*) [[AppManager sharedManager] cachedDicotionaryData:CACH_USER_FOLDER cachFile:CACH_DURATIONS_FILE];
	}
	return self;
}

#pragma mark -
#pragma mark User Login
// Check user logged in
- (BOOL)isUserLoggedIn
{
    if (userObject != nil)
    {
        if (userObject.sessionToken != nil)
            return YES;
    }
    return NO;
}

// User login and set the user dictionary data
- (void)userLogIn:(void (^)())loginSuccess failure:(void (^)(NSError *error))loginFailure
{
    // user login first with facebook
    [[SocialManager sharedManager] facebookLogin:^(NSDictionary *responseObject)
    {
        // try to login via server and link the facebook user
        [[ConnectionManager sharedManager] apiLogIn:responseObject success:^(id responseObject)
        {
            // fill user data
            NSDictionary *resultDic = responseObject;
            if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
            {
                userObject = [[User alloc] init];
                [userObject fillWithJSON:resultDic];
                // cach user data and save it in user memeber
                [[AppManager sharedManager] saveUserData:userObject];
                userObject = [[AppManager sharedManager] cachedUserData];
                loginSuccess();
            }
            else// error in response
                loginFailure(nil);
        }
        //server login failure
        failure:^(NSError *error)
        {
            loginFailure(error);
        }];
    }
    //facebook login failure     
    failure:^(NSError *error)
    {
        loginFailure(error);
    }];
}

// Logout from facebook and clear cached data
- (void)userLogout
{
    // remove facebook token
    [[SocialManager sharedManager] facebookLogout];
    userObject = nil;
    // remove cached user settings
    [[AppManager sharedManager] saveUserData:userObject];
    // clear cached images
    [[[SDWebImageManager sharedManager] imageCache] clearDisk];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    // remove all cached videos
    [[AppManager sharedManager] removeAllVideos];
    // clear arrays
    timelinesList = [[NSMutableArray alloc] init];
    messagesList = [[NSMutableArray alloc] init];
    topMessagesList = [[NSMutableArray alloc] init];
    timelinesLocationsList = [[NSMutableArray alloc] init];
    favLocationsList = [[NSMutableArray alloc] init];
    nearbyLocations = [[NSMutableArray alloc] init];
}

// Server login using facebook objcet
- (void)apiLogIn:(NSDictionary*)facebookObject success:(void (^)(id responseObject))apiLogInSuccess
                                failure:(void (^)(NSError *error))apiLogInFailure
{
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/fb_login", WEEZ_API_DOMAIN];
    // post the request to server login
    [manager POST:apiLink parameters:facebookObject progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            apiLogInFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            apiLogInFailure(nil);
        }
        else// user object
            apiLogInSuccess(responseObject);
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        apiLogInFailure(error);
    }];
}

// Upload user info
- (void)updateUserInfo:(User*)newUser withImage:(UIImage*)pickedImage success:(void (^)())updateUserInfoSuccess failure:(void (^)(NSError *error, int errorCode))updateUserInfoFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSMutableDictionary* neededDataDic = [[NSMutableDictionary alloc] init];
    if ([newUser.displayName length] > 0)
        [neededDataDic setObject:newUser.displayName forKey:@"name"];
    if ([newUser.username length] > 0)
        [neededDataDic setObject:newUser.username forKey:@"username"];
    if ([newUser.email length] > 0)
        [neededDataDic setObject:newUser.email forKey:@"email"];
    if ([newUser.bio length] > 0)
        [neededDataDic setObject:newUser.bio forKey:@"bio"];
    [neededDataDic setObject:newUser.phoneNumber forKey:@"phoneNumber"];
    [neededDataDic setObject:[NSNumber numberWithInt:newUser.imageDuration ] forKey:@"imageDuration"];
    [neededDataDic setObject:[NSNumber numberWithInt:newUser.chatPrivacyLevel ] forKey:@"chatSettings"];
    [neededDataDic setObject:[NSNumber numberWithBool:newUser.isPrivate] forKey:@"private"];
    [neededDataDic setObject:[NSNumber numberWithBool:newUser.notificationsFlagBoosts] forKey:@"boostNotification"];
    [neededDataDic setObject:[NSNumber numberWithBool:newUser.notificationsFlagMentions] forKey:@"mentionNotification"];
    [neededDataDic setObject:[NSNumber numberWithBool:newUser.notificationsFlagMessages] forKey:@"newMessageNotification"];
    [neededDataDic setObject:[NSNumber numberWithBool:newUser.notificationsFlagFollowers] forKey:@"newFollowerNotification"];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/update?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDataDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
    {
        // image exist
        if (pickedImage != nil)
        {
            double compressionRatio = 1.0;
            UIImage *resizedImage = [[AppManager sharedManager] resizeImage:pickedImage scaledToWidth:IMAGE_PROFILE_DIAMETER];
            NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
            int round = 0;
            while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
            {
                compressionRatio = compressionRatio * 0.9;
                data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                round++;
            }
            NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
            // image exist
            if (data != nil)
                [formData appendPartWithFileData:data name:@"profilePic" fileName:fileNameStr mimeType:@"image/jpg"];
        }
    }
    progress:^(NSProgress * _Nonnull uploadProgress)
    {
    }
    success:^(NSURLSessionTask *operation, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            updateUserInfoFailure(nil, 0);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            NSString *errorStr = (NSString*)[responseObject objectForKey:@"error"];
            // invalid username
            if ([errorStr isEqualToString:@"username_email_already_found"])
                updateUserInfoFailure(nil, 1);
            else// connection error
                updateUserInfoFailure(nil, 0);
        }
        else// user object
        {
            // update user info
            [userObject updateUserInfo:responseObject];
            // cach user data and save it in user memeber
            [[AppManager sharedManager] saveUserData:userObject];
            updateUserInfoSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        updateUserInfoFailure(error, 0);
    }];
}

// Get current user data
- (void)getCurrentUser:(void (^)())getCurrentUserSuccess failure:(void (^)(NSError *error))getCurrentUserFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/me?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the current user request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getCurrentUserFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            getCurrentUserFailure(nil);
        }
        else// user object
        {
            // fill user data
            NSDictionary *resultDic = responseObject;
            if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
            {
                // update user info
                [userObject updateUserInfo:resultDic];
                // cach user data and save it in user memeber
                [[AppManager sharedManager] saveUserData:userObject];
                userObject = [[AppManager sharedManager] cachedUserData];
                getCurrentUserSuccess();
            }
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error){
        getCurrentUserFailure(error);
    }];
}

// Get Global list
- (void)getGlobalList:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home/global_list?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the current user request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             onFailure(nil);
         }else{
             // fill user data
             NSDictionary *resultDic = responseObject;
             if ((resultDic != nil) && ([[resultDic allKeys] count] > 0)){
                 
                 reportTypes = [[NSMutableArray alloc] init];
                 NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"reportReasons"];
                 
                 // loop all sections
                 for (NSMutableDictionary *resultObj in resultList){
                     ReportType *obj = [[ReportType alloc] init];
                     [obj fillWithJSON:resultObj];
                     [reportTypes addObject:obj];
                 }
                 // cache report types
                 [[AppManager sharedManager] saveArrayData:reportTypes cachFolder:CACH_USER_FOLDER cachFile:CACH_REPORT_FILE];
                 
                 imageDurations = [[NSMutableArray alloc] init];
                 NSMutableArray *resultListDurations = (NSMutableArray*)[responseObject objectForKey:@"imageDurations"];
                 
                 // loop all sections
                 for (NSNumber *resultObj in resultListDurations){
                     [imageDurations addObject:resultObj];
                 }
                 // cache report types
                 [[AppManager sharedManager] saveArrayData:imageDurations cachFolder:CACH_USER_FOLDER cachFile:CACH_DURATIONS_FILE];
                 if(onSuccess)
                     onSuccess();
             }
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         if(onFailure)
             onFailure(error);
     }];
}

// Get current user data
- (void)getCurrentUserProfile:(void (^)(UserProfile*, Media*, int))getCurrentUserSuccess failure:(void (^)(NSError *error))getCurrentUserFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/profile?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the current user request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject){
        
        // no return object request timeout
        if (responseObject == nil)
            getCurrentUserFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil){
            // return error code
            getCurrentUserFailure(nil);
        }
        else{
            // fill user data
            NSDictionary *resultDic = responseObject;
            if ((resultDic != nil) && ([[resultDic allKeys] count] > 0)){
                
                // update user info
                NSDictionary *profileObject = [resultDic objectForKey:@"profile"];
                UserProfile *profile = [[UserProfile alloc] init];
                [profile fillWithJSON:profileObject];
                
                Media * lastViewedMedia = [[Media alloc] init];
                NSDictionary *mediaDict = [responseObject objectForKey:@"lastViewedMedia"];
                [lastViewedMedia fillWithJSON: mediaDict];
                
                int lastViewedIndex = (int)[[responseObject objectForKey:@"lastViewedIndex"] integerValue];
                
                getCurrentUserSuccess(profile, lastViewedMedia, lastViewedIndex);
            }
        }
    }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getCurrentUserFailure(error);
     }];
}

- (void)getUserNotifications: (void (^)(NSMutableArray*))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/inbox?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the current user request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else
         {
             // fill user data
             NSDictionary *resultDic = responseObject;
             if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
             {
                 id inbox = [responseObject objectForKey:@"inbox"];
                 NSMutableArray *arrayNotifications = [[NSMutableArray alloc] init];
                 NSMutableArray *resultList = (NSMutableArray*)[inbox objectForKey:@"notifications"];//followRequests
                 // loop all sections
                 for (NSMutableDictionary *resultObj in resultList)
                 {
                     AppNotification *obj = [[AppNotification alloc] init];
                     [obj fillWithJSON:resultObj];
                     [arrayNotifications addObject:obj];
                 }
                 onSuccess(arrayNotifications);
             }
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Get current user data
- (void)getUserProfile:(NSString *) userId onSucces:(void (^)(UserProfile*, Media*, int))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/profile/%@?access_token=%@", WEEZ_API_DOMAIN, userId, userObject.sessionToken];
    // post the current user request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            onFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            onFailure(nil);
        }
        else
        {
            // fill user data
            NSDictionary *resultDic = responseObject;
            if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
            {
                // update user info
                NSDictionary *profileObject = [resultDic objectForKey:@"profile"];
                UserProfile *profile = [[UserProfile alloc] init];
                [profile fillWithJSON:profileObject];
                
                Media * lastViewedMedia = [[Media alloc] init];
                NSDictionary *mediaDict = [responseObject objectForKey:@"lastViewedMedia"];
                [lastViewedMedia fillWithJSON: mediaDict];
                
                int lastViewedIndex = (int)[[responseObject objectForKey:@"lastViewedIndex"] integerValue];
                
                onSuccess(profile, lastViewedMedia, lastViewedIndex);
            }
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        onFailure(error);
    }];
}

#pragma mark -
#pragma mark Timeline
// Get timelines list
- (void)getTimelinesList:(int)page lattitude:(float)lat longitude:(float)lon success:(void (^)(BOOL withPages))getTimelinesListSuccess failure:(void (^)(NSError *error))getTimelinesListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // get last timelines id
    NSString *lastId = @"";
    NSString *lastMediaDate = nil;
    if (([timelinesList count] > 0) && (page > 0))
    {
        Timeline *t = (Timeline*)[timelinesList lastObject];
        lastId = t.userId;
        // set last updated date
        if (t.lastMediaDate != nil)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            lastMediaDate = [dateFormatter stringFromDate:t.lastMediaDate];
        }
    }
    
    NSMutableDictionary *neededDic = [[NSMutableDictionary alloc] init];
    [neededDic setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [neededDic setObject:lastId forKey:@"lastId"];
    if(lastMediaDate)
        [neededDic setObject:lastMediaDate forKey:@"lastMediaDate"];
    
    if(lat != 0 || lon != 0){
        [neededDic setObject:[NSNumber numberWithFloat:lat] forKey:@"lat"];
        [neededDic setObject:[NSNumber numberWithFloat:lon] forKey:@"long"];
    }
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             getTimelinesListFailure(nil);
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             getTimelinesListFailure(nil);
         } else// success
         {
             // first page to refresh the result
             if (page == 0)
             {
                 timelinesList = [[NSMutableArray alloc] init];
             }
             topMessagesList = [[NSMutableArray alloc] init];
             NSMutableArray *messagesResultList = (NSMutableArray*)[responseObject objectForKey:@"groups"];
             //fill in chat messages
             for (NSMutableDictionary *msgObj in messagesResultList)
             {
                 Timeline *message = [[Timeline alloc] init];
                 [message fillWithJSON:msgObj];
                 [topMessagesList addObject:message];
             }
             
             // fill in the data
             NSMutableArray *timelinesResultList = (NSMutableArray*)[responseObject objectForKey:@"timelines"];
             @try {
                 // fill in timelines
                 for (NSMutableDictionary *resultObj in timelinesResultList)
                 {
                     Timeline *timelineObj = [[Timeline alloc] init];
                     [timelineObj fillWithJSON:resultObj];
                     [timelinesList addObject:timelineObj];
                 }
             } @catch (NSException *exception) {
                 NSLog(@"%@",[[exception userInfo] description]);
             }
             
             //trending locations
             timelinesLocationsList = [[NSMutableArray alloc] init];
             NSMutableArray *locationsResultList = (NSMutableArray*)[responseObject objectForKey:@"trendingLocations"];
             // loop all sections
             for (NSMutableDictionary *resultObj in locationsResultList)
             {
                 Location *locationObj = [[Location alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [timelinesLocationsList addObject:locationObj];
             }
             // check for new page
             BOOL withNewPage = NO;
             if ([timelinesResultList count] > 0)
                 withNewPage = YES;
             // success result
             getTimelinesListSuccess(withNewPage);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getTimelinesListFailure(error);
     }];
}
//get timelines list
- (void)getTagTimelines:(int)page TagId:(NSString*)tagId success:(void (^)(NSString *tagId, BOOL withPages, NSMutableArray*))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    
    NSDictionary* neededDic = @{@"page": [NSNumber numberWithInt:page], @"tag": tagId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@hashtags/?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         else// success
         {
             // first page to refresh the result
             NSMutableArray *timelines = [[NSMutableArray alloc] init];
             // fill in the data
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"users"];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Timeline *timelineObj = [[Timeline alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [timelines addObject:timelineObj];
             }
             
             // check for new page
             BOOL withNewPage = NO;
             if ([resultList count] > 0)
                 withNewPage = YES;
             // success result
             onSuccess(tagId, withNewPage, timelines);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Get page of timelines of media related to a specific location
- (void)getLocationTimelines:(int)page LocationId:(NSString*)locationId lastId:(NSString*)lastId success:(void (^)(NSString *locationId, BOOL withPages, NSMutableArray* friends, NSMutableArray* all))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    if(lastId == nil){
        onFailure(nil);
        return;
    }
    NSDictionary* neededDic = @{@"page": [NSNumber numberWithInt:page], @"lastId": lastId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/location/%@?access_token=%@", WEEZ_API_DOMAIN, locationId, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         id timelinesObject = [responseObject objectForKey:@"timelines"];
         
         // no return object request timeout
         if (responseObject == nil || timelinesObject == nil)
             onFailure(nil);
         else// success
         {
             // first page to refresh the result
             NSMutableArray *allTimelines = [[NSMutableArray alloc] init];
             NSMutableArray *friendsTimelines = [[NSMutableArray alloc] init];
             // fill in the data
             NSMutableArray *allList = (NSMutableArray*)[timelinesObject objectForKey:@"all"];
             NSMutableArray *friendsList = (NSMutableArray*)[timelinesObject objectForKey:@"followings"];
             // loop all section
             for (NSMutableDictionary *resultObj in allList)
             {
                 Timeline *timelineObj = [[Timeline alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [allTimelines addObject:timelineObj];
             }
             // loop freinds section
             for (NSMutableDictionary *resultObj in friendsList)
             {
                 Timeline *timelineObj = [[Timeline alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [friendsTimelines addObject:timelineObj];
             }
             
             // check for new page of all timelines
             BOOL withNewPage = NO;
             if ([allList count] > 0)
                 withNewPage = YES;
             // success result
             onSuccess(locationId, withNewPage, friendsTimelines, allTimelines);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Search for timeline
- (void)searchForTimeline:(NSString*)keyword success:(void (^)(NSMutableArray *timelineList))searchForTimelineSuccess failure:(void (^)(NSError *error))searchForTimelineFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"q":keyword};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home/search?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        
        // no return object request timeout
        if (responseObject == nil)
            searchForTimelineFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            searchForTimelineFailure(nil);
        }
        else// success
        {
            // fill in the data
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"timelines"];
            NSMutableArray *listOfTimelines = [[NSMutableArray alloc] init];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Timeline *timelineObj = [[Timeline alloc] init];
                [timelineObj fillWithJSON:resultObj];
                [listOfTimelines addObject:timelineObj];
            }
            searchForTimelineSuccess(listOfTimelines);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        searchForTimelineFailure(error);
    }];
}

// Get timeline media
- (void)getTimelineMedia:(Timeline*)timeline success:(void (^)(NSMutableArray *mediaList, int startIndex))getTimelineMediaSuccess failure:(void (^)(NSError *error))getTimelineMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // ad certian media id
    if ([timeline.mediaId length] > 0)
        neededDic = @{@"media_id" : timeline.mediaId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/%@?access_token=%@", WEEZ_API_DOMAIN, timeline.userId, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        NSString *error = (NSString *)[responseObject objectForKey:@"error"];
        
        if(error)
        {
            NSError *errorObject = [[NSError alloc]initWithDomain:@"Weez.Timeline.Media" code:ERROR_PRIVECY userInfo:nil];
            getTimelineMediaFailure(errorObject);
        }
        // no return object request timeout
        else if (responseObject == nil)
        {
         getTimelineMediaFailure(nil);
        }
        else// success
        {
            NSMutableArray *listOfMedia = [[NSMutableArray alloc] init];
            // fill in the data
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"timeline"];
            int viewedIndex = [[responseObject objectForKey:@"lastViewedIndex"] intValue];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Media *mediaObj = [[Media alloc] init];
                [mediaObj fillWithJSON:resultObj];
                [listOfMedia addObject:mediaObj];
            }
            // success result
            getTimelineMediaSuccess(listOfMedia, viewedIndex);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getTimelineMediaFailure(error);
    }];
}

// Upload media
- (void)uploadMedia:(MediaType)mediaType withLocation:(NSString*)locationId
        withEventId:(NSString*)eventId
          withVideo:(NSURL*)videoURL
          withImage:(UIImage*)pickedImage
     withRecipients:(NSMutableArray*)recipients
        withGroups :(NSMutableArray*)groups
         withPublic:(BOOL)isPublic withHashtags:(NSMutableArray*)hashtags
            success:(void (^)())uploadMediaSuccess
            failure:(void (^)(NSError *error, int errorCode))uploadMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSMutableDictionary* neededDic = [[NSMutableDictionary alloc] init];
    [neededDic setObject:[NSNumber numberWithInt:mediaType] forKey:@"type"];
    [neededDic setObject:locationId forKey:@"locationId"];
    [neededDic setObject:eventId forKey:@"eventId"];
    [neededDic setObject:recipients forKey:@"recipients"];
    [neededDic setObject:hashtags forKey:@"hashtags"];
    [neededDic setObject:groups forKey:@"groups"];
    [neededDic setObject:[NSNumber numberWithBool:isPublic] forKey:@"public"];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/upload?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
    {
        // image case
        if (mediaType == kMediaTypeImage)
        {
            double compressionRatio = 1.0;
            NSData *data = UIImageJPEGRepresentation(pickedImage, compressionRatio);
            int round = 0;
            while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
            {
                compressionRatio = compressionRatio * 0.9;
                data = UIImageJPEGRepresentation(pickedImage, compressionRatio);
                round++;
            }
            NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
            // image exist
            if (data != nil)
                [formData appendPartWithFileData:data name:@"media" fileName:fileNameStr mimeType:@"image/jpg"];
        }
        // video case
        else if (mediaType == kMediaTypeVideo)
        {
            NSString *path = [videoURL path];
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
            NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            fileNameStr = [fileNameStr stringByAppendingString:@".mp4"];
            // video exist
            if (data != nil)
                [formData appendPartWithFileData:data name:@"media" fileName:fileNameStr mimeType:@"video/mp4"];
        }
    }
    progress:^(NSProgress * _Nonnull uploadProgress)
    {
    }
    success:^(NSURLSessionTask *operation, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            uploadMediaFailure(nil, 0);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            uploadMediaFailure(nil, 1);
        }
        else// success
        {
            uploadMediaSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        uploadMediaFailure(error, 0);
    }];
}

// Upload media
- (void)uploadMedia:(MediaType)mediaType withCustomLocation:(Location*)location
        withEventId:(NSString*)eventId
          withVideo:(NSURL*)videoURL
          withImage:(UIImage*)pickedImage
     withRecipients:(NSMutableArray*)recipients
        withGroups :(NSMutableArray*)groups
         withPublic:(BOOL)isPublic withHashtags:(NSMutableArray*)hashtags
            success:(void (^)())onSuccess
            failure:(void (^)(NSError *error, int errorCode))onFailure
{
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSMutableDictionary* neededDic = [[NSMutableDictionary alloc] init];
    [neededDic setObject:location.name forKey:@"name"];
    [neededDic setObject:location.objectId forKey:@"placeId"];
    [neededDic setObject:location.address forKey:@"address"];
    [neededDic setObject:[NSNumber numberWithFloat:location.latitude] forKey:@"lat"];
    [neededDic setObject:[NSNumber numberWithFloat:location.longitude ] forKey:@"long"];
    [neededDic setObject:[NSNumber numberWithBool:location.isUnDefinedPlace] forKey:@"private"];
    if(location.country)
        [neededDic setObject:location.country forKey:@"country"];
    if(location.city)
        [neededDic setObject:location.city forKey:@"city"];
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/places?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil, 0);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil, 0);
         }
         else// location created successfully, now upload media
         {
             Location *newLocation = [[Location alloc] init];
             [newLocation fillWithJSON:[responseObject objectForKey:@"location"]];
             
             [self uploadMedia:mediaType withLocation:newLocation.objectId withEventId:@"" withVideo:videoURL withImage:pickedImage withRecipients:recipients withGroups:groups withPublic:isPublic withHashtags:hashtags success:onSuccess failure:onFailure];
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error, 0);
     }];
}

- (void)createLocation:(Location*)location
            success:(void (^)(Location*))onSuccess
            failure:(void (^)(NSError *error, int errorCode))onFailure
{
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSMutableDictionary* neededDic = [[NSMutableDictionary alloc] init];
    [neededDic setObject:location.name forKey:@"name"];
    [neededDic setObject:location.objectId forKey:@"placeId"];
    [neededDic setObject:location.address forKey:@"address"];
    [neededDic setObject:[NSNumber numberWithFloat:location.latitude] forKey:@"lat"];
    [neededDic setObject:[NSNumber numberWithFloat:location.longitude ] forKey:@"long"];
    [neededDic setObject:[NSNumber numberWithBool:location.isUnDefinedPlace ] forKey:@"private"];
    if(location.country)
        [neededDic setObject:location.country forKey:@"country"];
    if(location.city)
        [neededDic setObject:location.city forKey:@"city"];
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/places?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil, 0);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil, 0);
         }
         else// location created successfully, now upload media
         {
             Location *newLocation = [[Location alloc] init];
             [newLocation fillWithJSON:[responseObject objectForKey:@"location"]];
             onSuccess(newLocation);
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error, 0);
     }];
}


// Watch certain media for certain user
- (void)watchMedia:(NSString*)userId withMediaId:(NSString*)mediaId success:(void (^)())watchMediaSuccess failure:(void (^)(NSError *error))watchMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{@"forUser": userId, @"mediaId": mediaId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/watch?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             watchMediaFailure(nil);
         else// success
             watchMediaSuccess();
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         watchMediaFailure(error);
     }];
}

// Boost certain media for certain user
- (void)boostMedia:(NSString*)userId withMediaId:(NSString*)mediaId success:(void (^)())boostMediaSuccess failure:(void (^)(NSError *error))boostMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{@"forUser": userId, @"mediaId": mediaId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/boost?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            boostMediaFailure(nil);
        else// success
            boostMediaSuccess();
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        boostMediaFailure(error);
    }];
}

// Mention list of users for media
- (void)mentionMedia:(NSString*)userId withMediaId:(NSString*)mediaId withMentionList:(NSMutableArray*)mentionList success:(void (^)())mentionMediaSuccess failure:(void (^)(NSError *error))mentionMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{@"forUser": userId, @"mediaId": mediaId, @"mentionList": mentionList};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/mention?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            mentionMediaFailure(nil);
        else// success
            mentionMediaSuccess();
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        mentionMediaFailure(error);
    }];
}

/// delete timeline media
- (void)deleteMedia:(NSString*)mediaId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"mediaId" : mediaId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/delete?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else// success
         {
             onSuccess();
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

#pragma mark -
#pragma mark Map
// Get list of favorite locations
- (void)getFavoriteLocations:(void (^)(NSMutableArray *))onSuccess failure:(void (^)(NSError *))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/favorite?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         else// success
         {
             favLocationsList = [[NSMutableArray alloc] init];
             // fill fav locations data
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"favoriteLocations"];
             for (NSMutableDictionary *resultObj in resultList){
                 Location *timelineObj = [[Location alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [favLocationsList addObject:timelineObj];
             }
             
             onSuccess(favLocationsList);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Get locations arround the defined location contained in the sent diameter
- (void)getTrendingLocationsListNear:(float)lat long:(float)lon withRadius:(double)radius success:(void (^)(NSMutableArray *locations))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{@"long": [NSNumber numberWithFloat:lon], @"lat": [NSNumber numberWithFloat:lat], @"radius": [NSNumber numberWithDouble:(int)radius]};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/near?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         else// success
         {
             NSMutableArray *locations = [[NSMutableArray alloc] init];
             // fill in the data
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"locations"];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Location *timelineObj = [[Location alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [locations addObject:timelineObj];
             }
             onSuccess(locations);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

#pragma mark -
#pragma mark Search
- (void)search:(NSString*)keyword for:(SearchMode) searchMode success:(void (^)(NSMutableArray *usersList, SearchMode searchMode))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSUInteger type = 0;
    if(searchMode == searchModeLocations)
        type = 2;
    else if(searchMode == searchModeTags)
        type = 1;
    // needed dictionary
    NSDictionary* neededDic = @{@"q":keyword};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home/search?access_token=%@&type=%lu", WEEZ_API_DOMAIN, userObject.sessionToken, (long)type];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else// success
         {
             // fill in the data
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"data"];
             NSMutableArray *listOfResults = [[NSMutableArray alloc] init];
             
             if(searchMode == searchModeUsers){ // result is array of users
                 // loop all users
                 for (NSMutableDictionary *resultObj in resultList)
                 {
                     Friend *friendObj = [[Friend alloc] init];
                     [friendObj fillWithJSON:resultObj];
                     [listOfResults addObject:friendObj];
                 }
             }else if(searchMode == searchModeLocations){ // result is array od locations
                 // loop all locations
                 for (NSMutableDictionary *resultObj in resultList)
                 {
                     Location *locationObj = [[Location alloc] init];
                     [locationObj fillWithJSON:resultObj];
                     [listOfResults addObject:locationObj];
                 }
             }else if(searchMode == searchModeTags){ // results is array of Tags
                 for (NSMutableDictionary *resultObj in resultList)
                 {
                     Tag *tagObj = [[Tag alloc] init];
                     [tagObj fillWithJSON:resultObj];
                     [listOfResults addObject:tagObj];
                 }
             }
             
             onSuccess(listOfResults, searchMode);
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}


- (void)searchForTop:(void (^)(NSMutableDictionary *topFeeds))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"q":@""};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home/search/top?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else// success
         {
             //top users
             NSMutableArray *topUsersJson = (NSMutableArray*)[responseObject objectForKey:@"topUsers"];
             NSMutableArray *topUsers = [[NSMutableArray alloc] init];
             for (NSMutableDictionary *resultObj in topUsersJson)
             {
                 Friend *friendObj = [[Friend alloc] init];
                 [friendObj fillWithJSON:resultObj];
                 [topUsers addObject:friendObj];
             }
             //top loactions
             NSMutableArray *topLocationsJson = (NSMutableArray*)[responseObject objectForKey:@"topLocations"];
             NSMutableArray *topLocations = [[NSMutableArray alloc] init];
             for (NSMutableDictionary *resultObj in topLocationsJson)
             {
                 Location *locationObj = [[Location alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [topLocations addObject:locationObj];
             }
             //Top tags
             NSMutableArray *topTagsJson = (NSMutableArray*)[responseObject objectForKey:@"topHashes"];
             NSMutableArray *topTags = [[NSMutableArray alloc] init];
             for (NSMutableDictionary *resultObj in topTagsJson)
             {
                 Tag *tagObj = [[Tag alloc] init];
                 [tagObj fillWithJSON:resultObj];
                 [topTags addObject:tagObj];
             }
             // fill in the data
             NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
             [data setObject:topUsers forKey:@"USERS"];
             [data setObject:topLocations forKey:@"LOCATIONS"];
             [data setObject:topTags forKey:@"TAGS"];
             
             onSuccess(data);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

#pragma mark -
#pragma mark Friends
// Search for user by username
- (void)searchForUser:(NSString*)username success:(void (^)(NSMutableArray *usersList))searchForUserSuccess failure:(void (^)(NSError *error))searchForUserFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"username":username};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/search?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            searchForUserFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            searchForUserFailure(nil);
        }
        else// success
        {
            // fill in the data
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"users"];
            NSMutableArray *listOfUsers = [[NSMutableArray alloc] init];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Friend *friendObj = [[Friend alloc] init];
                [friendObj fillWithJSON:resultObj];
                [listOfUsers addObject:friendObj];
            }
            searchForUserSuccess(listOfUsers);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        searchForUserFailure(error);
    }];
}

// Follow user
- (void)followUser:(NSString*)userId success:(void (^)())followUserSuccess failure:(void (^)(NSError *error))followUserFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"userId":userId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/follow?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            followUserFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            followUserFailure(nil);
        }
        else// success
        {
            // refresh current user
            [[ConnectionManager sharedManager] getCurrentUser:^
            {
            }
            failure:^(NSError *error)
            {
            }];
            followUserSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        followUserFailure(error);
    }];
}


// report user
- (void)reportUser:(NSString*)userId reportType:(int)reportType success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"userId":userId, @"type":[NSNumber numberWithInt:reportType]};
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/report?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject){
        // no return object request timeout
        if (responseObject == nil)
            onFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil){
            // return error code
            onFailure(nil);
        }else{
            onSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        onFailure(error);
    }];
}

// Search for user by username
- (void)getFollowingList:(FollowType)followType rankedBy:(TimelineType)listType success:(void (^)(NSMutableArray *usersList))getFollowingListSuccess failure:(void (^)(NSError *error))getFollowingListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSString *rankByString = @"";
    if(listType == kTimelineTypeGroup)
        rankByString = @"chat";
    else if(listType == kTimelineTypeMention)
        rankByString = @"mention";
    else
        rankByString = @"boost";

    NSDictionary* neededDic = @{@"rankBy":rankByString};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/followings_list?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    if (followType == kFollowTypeFollowers)
        apiLink = [NSString stringWithFormat:@"%@users/followers_list?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             getFollowingListFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             getFollowingListFailure(nil);
         }
         else// success
         {
             // fill in the data
             NSString *resultKey = @"followings";
             if (followType == kFollowTypeFollowers)
                 resultKey = @"followers";
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:resultKey];
             NSMutableArray *listOfUsers = [[NSMutableArray alloc] init];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Friend *friendObj = [[Friend alloc] init];
                 [friendObj fillWithJSON:resultObj];
                 [listOfUsers addObject:friendObj];
             }
             getFollowingListSuccess(listOfUsers);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getFollowingListFailure(error);
     }];
}

// Get mention list
- (void)getMentionList:(void (^)(NSMutableArray *mentionList))getMentionListSuccess failure:(void (^)(NSError *error))getMentionListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/mention_list?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getMentionListFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            getMentionListFailure(nil);
        }
        else// success
        {
            // fill in the data
            NSMutableArray *listOfTimelines = [[NSMutableArray alloc] init];
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"mentions"];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Timeline *timelineObj = [[Timeline alloc] init];
                [timelineObj fillWithJSON:resultObj];
                [listOfTimelines addObject:timelineObj];
            }
            getMentionListSuccess(listOfTimelines);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getMentionListFailure(error);
    }];
}

// Get recipients list (following users & chat groups)
- (void)getRecipientsListRankedBy:(NSString*)rankBy onSuccess:(void (^)(NSMutableArray *usersList, NSMutableArray *groupsList))getRecipientsListSuccess failure:(void (^)(NSError *error))getRecipientsListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"rankBy":rankBy};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@users/recipients_list?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getRecipientsListFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            getRecipientsListFailure(nil);
        }
        else// success
        {
            // fill in the data
            NSMutableArray *resultListFollowing = (NSMutableArray*)[responseObject objectForKey:@"followings"];
            NSMutableArray *resultListGroups = (NSMutableArray*)[responseObject objectForKey:@"groups"];
            NSMutableArray *listOfUsers = [[NSMutableArray alloc] init];
            NSMutableArray *listOfGroups = [[NSMutableArray alloc] init];
            // loop all users
            for (NSMutableDictionary *resultObj in resultListFollowing)
            {
                Friend *friendObj = [[Friend alloc] init];
                [friendObj fillWithJSON:resultObj];
                [listOfUsers addObject:friendObj];
            }
            // loop all groups
            for (NSMutableDictionary *resultObj in resultListGroups)
            {
                Group *groupObj = [[Group alloc] init];
                [groupObj fillWithJSON:resultObj];
                [listOfGroups addObject:groupObj];
            }
            getRecipientsListSuccess(listOfUsers, listOfGroups);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getRecipientsListFailure(error);
    }];
}

#pragma mark -
#pragma mark Location
// Follow location
- (void)followLocation:(NSString*)locationId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"locationId":locationId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/follow?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             onFailure(nil);
         }
         else{
             // refresh current user
             [[ConnectionManager sharedManager] getCurrentUser:^{}
                failure:^(NSError *error){
              }];
             onSuccess();
         }
     }
    failure:^(NSURLSessionTask *operation, NSError *error){
         onFailure(error);
     }];
}

// Get next timeline in location
- (void)getNextTimelineInLocation:(NSString*)locationId orEvent:(NSString*)eventId next:(BOOL)next currentlyWatchedUserId:(NSString*) currentUserId dateOfCurrentTimeline:(NSString*) dateOfCurrentTimeline success:(void (^)(Timeline*,NSMutableArray*, int, BOOL))onSuccess failure:(void (^)(NSDictionary *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"user_id":currentUserId, @"date":dateOfCurrentTimeline};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink ;
    if(eventId && [eventId length] > 0)
        apiLink = [NSString stringWithFormat:@"%@timelines/event/%@/%@?access_token=%@", WEEZ_API_DOMAIN, eventId, next?@"next":@"prev", userObject.sessionToken];
    else
        apiLink = [NSString stringWithFormat:@"%@timelines/location/%@/%@?access_token=%@", WEEZ_API_DOMAIN, locationId, next?@"next":@"prev", userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        // no return object request timeout
        if (responseObject == nil)
            onFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil){
            // return error code
            onFailure(responseObject);
        }else{
            // timeline
            Timeline *timelineObj = [[Timeline alloc] init];
            [timelineObj fillWithJSON:[responseObject objectForKey:@"user"]];
            
            // timeline media list
            NSMutableArray *listOfMedia = [[NSMutableArray alloc] init];
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"timeline"];
            for (NSMutableDictionary *resultObj in resultList){
                Media *mediaObj = [[Media alloc] init];
                [mediaObj fillWithJSON:resultObj];
                [listOfMedia addObject:mediaObj];
            }
            
            // last viewed index
            int viewedIndex = [[responseObject objectForKey:@"lastViewedIndex"] intValue];
            
            // has more
            BOOL hasMore;
            //if([responseObject objectForKey:@"hasPrev"] != nil){
            if(!next){
                hasMore = [[responseObject objectForKey:@"hasPrev"] boolValue];
            }else{
                hasMore = [[responseObject objectForKey:@"hasNext"] boolValue];
            }
            
            // success result
            onSuccess(timelineObj, listOfMedia, viewedIndex, hasMore);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error){
        onFailure([error userInfo]);
    }];
}

/// Get timeline media in a certain location
- (void)getTimelineMediaInLocation:(NSString*)userId locationId:(NSString*)locationId success:(void (^)(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev))getTimelineMediaSuccess failure:(void (^)(NSError *error))getTimelineMediaFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/location/%@/%@?access_token=%@", WEEZ_API_DOMAIN, locationId, userId, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getTimelineMediaFailure(nil);
        else// success
        {
            NSMutableArray *listOfMedia = [[NSMutableArray alloc] init];
            // fill in the data
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"timeline"];
            int viewedIndex = [[responseObject objectForKey:@"lastViewedIndex"] intValue];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Media *mediaObj = [[Media alloc] init];
                [mediaObj fillWithJSON:resultObj];
                [listOfMedia addObject:mediaObj];
            }
            // has more
            BOOL hasPrev = [[responseObject objectForKey:@"hasPrev"] boolValue];
            BOOL hasNext = [[responseObject objectForKey:@"hasNext"] boolValue];
             
            // success result
            getTimelineMediaSuccess(listOfMedia, viewedIndex, hasNext, hasPrev);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getTimelineMediaFailure(error);
    }];
}

// Get full list of locations
- (void)getLocationsList:(BOOL)myLocations success:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations?access_token=%@&lat=%f&long=%f", WEEZ_API_DOMAIN, userObject.sessionToken, [AppManager sharedManager].currenttUserLocation.coordinate.latitude, [AppManager sharedManager].currenttUserLocation.coordinate.longitude];
    if (myLocations)
        apiLink = [NSString stringWithFormat:@"%@locations/my_locations?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getLocationsListFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            getLocationsListFailure(nil);
        }
        else// success
        {
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"locations"];
            NSMutableArray *listOfLocations = [[NSMutableArray alloc] init];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Location *locationObj = [[Location alloc] init];
                [locationObj fillWithJSON:resultObj];
                [listOfLocations addObject:locationObj];
            }
            
            // we also have a list of events
            NSMutableArray *listOfEvents = [[NSMutableArray alloc] init];
            if(!myLocations){
                NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"events"];
                // loop all sections
                for (NSMutableDictionary *resultObj in resultList)
                {
                    Event *locationObj = [[Event alloc] init];
                    [locationObj fillWithJSON:resultObj];
                    [listOfEvents addObject:locationObj];
                }
                
            }
            getLocationsListSuccess(listOfLocations, listOfEvents);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getLocationsListFailure(error);
    }];
}

- (void)getLocationsAndEventsListSuccess:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList, NSMutableArray *placesList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations?access_token=%@&lat=%f&long=%f", WEEZ_API_DOMAIN, userObject.sessionToken, [AppManager sharedManager].currenttUserLocation.coordinate.latitude, [AppManager sharedManager].currenttUserLocation.coordinate.longitude];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             getLocationsListFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             getLocationsListFailure(nil);
         }else{// success
             
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"locations"];
             NSMutableArray *listOfLocations = [[NSMutableArray alloc] init];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Location *locationObj = [[Location alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [listOfLocations addObject:locationObj];
             }
             
             // we also have a list of events
             NSMutableArray *listOfEvents = [[NSMutableArray alloc] init];
             resultList = (NSMutableArray*)[responseObject objectForKey:@"events"];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList){
                 Event *locationObj = [[Event alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [listOfEvents addObject:locationObj];
             }
             
             // we also have a list of events
             NSMutableArray *listOfPlaces = [[NSMutableArray alloc] init];
             resultList = (NSMutableArray*)[responseObject objectForKey:@"places"];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList){
                 Location *locationObj = [[Location alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 locationObj.isUnDefinedPlace = YES;
                 locationObj.objectId = [resultObj objectForKey:@"placesId"];
                 [listOfPlaces addObject:locationObj];
                 
             }
             getLocationsListSuccess(listOfLocations, listOfEvents, listOfPlaces);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getLocationsListFailure(error);
     }];
}

/// get locations a users checked in "recorded media in"
- (void)getLocationsRelatedTo:(NSString *)userId success:(void (^)(NSMutableArray *locationsList, NSMutableArray *eventsList))getLocationsListSuccess failure:(void (^)(NSError *error))getLocationsListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/unique/?user_id=%@&access_token=%@", WEEZ_API_DOMAIN, userId, userObject.sessionToken];
    
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             getLocationsListFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             getLocationsListFailure(nil);
         }
         else// success
         {
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"locations"];
             NSMutableArray *listOfLocations = [[NSMutableArray alloc] init];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList){
                 Location *locationObj = [[Location alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [listOfLocations addObject:locationObj];
             }
             
             resultList = (NSMutableArray*)[responseObject objectForKey:@"events"];
             NSMutableArray *listOfEvents = [[NSMutableArray alloc] init];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList){
                 Event *locationObj = [[Event alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [listOfEvents addObject:locationObj];
             }
             
             getLocationsListSuccess(listOfLocations, listOfEvents);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getLocationsListFailure(error);
     }];
}

// Upload locagtion info
- (void)updateLocation:(Location*)location withImage:(UIImage*)pickedImage withCover:(UIImage*)coverImage success:(void (^)())updateLocationSuccess failure:(void (^)(NSError *error, int errorCode))updateLocationFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSDictionary* neededDataDic = @{@"name": location.name, @"address": location.address, @"city": location.city, @"country": location.country, @"countryCode": location.countryCode, @"lat": [NSNumber numberWithFloat:location.latitude], @"long": [NSNumber numberWithFloat:location.longitude]};
    // set location id if exist
    NSString *locationId = @"";
    if ((location.objectId != nil) && ([location.objectId length] > 0))
        locationId = [NSString stringWithFormat:@"/%@", location.objectId];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@locations/my_locations%@?access_token=%@", WEEZ_API_DOMAIN, locationId, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDataDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
    {
        // image exist
        if (pickedImage != nil)
        {
            double compressionRatio = 1.0;
            UIImage *resizedImage = [[AppManager sharedManager] resizeImage:pickedImage scaledToWidth:IMAGE_PROFILE_DIAMETER];
            NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
            int round = 0;
            while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
            {
                compressionRatio = compressionRatio * 0.9;
                data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                round++;
            }
            NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
            // image exist
            if (data != nil)
                [formData appendPartWithFileData:data name:@"image" fileName:fileNameStr mimeType:@"image/jpg"];
        }
        // cover exist
        if (coverImage != nil)
        {
            double compressionRatio = 1.0;
            UIImage *resizedImage = [[AppManager sharedManager] resizeImage:coverImage scaledToHeight:IMAGE_COVER_HEIGHT];
            NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
            int round = 0;
            while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
            {
                compressionRatio = compressionRatio * 0.9;
                data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                round++;
            }
            NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
            // image exist
            if (data != nil)
                [formData appendPartWithFileData:data name:@"cover" fileName:fileNameStr mimeType:@"image/jpg"];
        }
    }
    progress:^(NSProgress * _Nonnull uploadProgress)
    {
    }
    success:^(NSURLSessionTask *operation, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            updateLocationFailure(nil, 0);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            updateLocationFailure(nil, 0);
        }
        else// location object
        {
            updateLocationSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        updateLocationFailure(error, 0);
    }];
}

#pragma mark -
#pragma mark Events
// Follow location
- (void)followEvent:(NSString*)eventId success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"eventId":eventId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@events/follow?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        // no return object request timeout
        if (responseObject == nil)
            onFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil){
            // return error code
            onFailure(nil);
        }
        else{
            // refresh current user
            [[ConnectionManager sharedManager] getCurrentUser:^{}
                                                      failure:^(NSError *error){
                                                      }];
            onSuccess();
        }
    }
          failure:^(NSURLSessionTask *operation, NSError *error){
              onFailure(error);
          }];
}

// Upload group info
- (void)updateEvent:(Event*)newEvent withLocationId:(NSString *) locationId withImage:(UIImage*)pickedImage withCover:(UIImage*)coverImage success:(void (^)())onSuccess failure:(void (^)(NSError *error, int errorCode))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSString *startDate = [formatter stringFromDate:newEvent.startDate];
    NSString *endDate = [formatter stringFromDate:newEvent.endDate];
    
    // needed data
    NSDictionary* neededDataDic;
    if(locationId && [locationId length] > 0)
        neededDataDic = @{@"name": newEvent.name, @"startDate": startDate, @"endDate": endDate, @"locationId":locationId};
    else
        neededDataDic = @{@"name": newEvent.name, @"startDate": startDate, @"endDate": endDate};
    // set group id if exist
    NSString *groupId = @"";
    if ((newEvent.objectId != nil) && ([newEvent.objectId length] > 0))
        groupId = [NSString stringWithFormat:@"/%@", newEvent.objectId];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@events%@?access_token=%@", WEEZ_API_DOMAIN, groupId, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDataDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
     {
         // image exist
         if (pickedImage != nil)
         {
             double compressionRatio = 1.0;
             UIImage *resizedImage = [[AppManager sharedManager] resizeImage:pickedImage scaledToWidth:IMAGE_PROFILE_DIAMETER];
             NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
             int round = 0;
             while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
             {
                 compressionRatio = compressionRatio * 0.9;
                 data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                 round++;
             }
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
             // image exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"image" fileName:fileNameStr mimeType:@"image/jpg"];
         }
         
         // cover exist
         if (coverImage != nil)
         {
             double compressionRatio = 1.0;
             UIImage *resizedImage = [[AppManager sharedManager] resizeImage:coverImage scaledToHeight:IMAGE_COVER_HEIGHT];
             NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
             int round = 0;
             while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
             {
                 compressionRatio = compressionRatio * 0.5;
                 data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                 round++;
             }
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
             // image exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"cover" fileName:fileNameStr mimeType:@"image/jpg"];
         }
     }
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
     }
          success:^(NSURLSessionTask *operation, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil, 0);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             onFailure(nil, 0);
         }
         else// group object
         {
             onSuccess();
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error, 0);
     }];
}

- (void)getMyEventsList:(void (^)(NSMutableArray *locationsList))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
    return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@events/my_events?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else// success
         {
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"events"];
             NSMutableArray *listOfLocations = [[NSMutableArray alloc] init];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Event *locationObj = [[Event alloc] init];
                 [locationObj fillWithJSON:resultObj];
                 [listOfLocations addObject:locationObj];
             }
             onSuccess(listOfLocations);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Get page of timelines of media related to a specific event
- (void)getEventTimelines:(int)page eventId:(NSString*)eventId lastId:(NSString*)lastId success:(void (^)(NSString *eventId, BOOL withPages, NSMutableArray* newFriends, NSMutableArray* newTimelines))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    if(lastId == nil){
        onFailure(nil);
        return;
    }
    NSDictionary* neededDic = @{@"page": [NSNumber numberWithInt:page], @"lastId": lastId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/event/%@?access_token=%@", WEEZ_API_DOMAIN, eventId, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         id timelinesObject = [responseObject objectForKey:@"timelines"];
         
         // no return object request timeout
         if (responseObject == nil || timelinesObject == nil)
             onFailure(nil);
         else// success
         {
             // first page to refresh the result
             NSMutableArray *allTimelines = [[NSMutableArray alloc] init];
             NSMutableArray *friendsTimelines = [[NSMutableArray alloc] init];
             // fill in the data
             NSMutableArray *allList = (NSMutableArray*)[timelinesObject objectForKey:@"all"];
             NSMutableArray *friendsList = (NSMutableArray*)[timelinesObject objectForKey:@"followings"];
             // loop all section
             for (NSMutableDictionary *resultObj in allList)
             {
                 Timeline *timelineObj = [[Timeline alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [allTimelines addObject:timelineObj];
             }
             // loop freinds section
             for (NSMutableDictionary *resultObj in friendsList)
             {
                 Timeline *timelineObj = [[Timeline alloc] init];
                 [timelineObj fillWithJSON:resultObj];
                 [friendsTimelines addObject:timelineObj];
             }
             
             // check for new page of all timelines
             BOOL withNewPage = NO;
             if ([allList count] > 0)
                 withNewPage = YES;
             // success result
             onSuccess(eventId, withNewPage, friendsTimelines, allTimelines);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

// Get timeline media in a certain location
- (void)getTimelineMediaInEvent:(NSString*)userId eventId:(NSString*)eventId success:(void (^)(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@timelines/event/%@/%@?access_token=%@", WEEZ_API_DOMAIN, eventId, userId, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         else// success
         {
             NSMutableArray *listOfMedia = [[NSMutableArray alloc] init];
             // fill in the data
             NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"timeline"];
             int viewedIndex = [[responseObject objectForKey:@"lastViewedIndex"] intValue];
             // loop all sections
             for (NSMutableDictionary *resultObj in resultList)
             {
                 Media *mediaObj = [[Media alloc] init];
                 [mediaObj fillWithJSON:resultObj];
                 [listOfMedia addObject:mediaObj];
             }
             // has more
             BOOL hasPrev = [[responseObject objectForKey:@"hasPrev"] boolValue];
             BOOL hasNext = [[responseObject objectForKey:@"hasNext"] boolValue];
             
             // success result
             onSuccess(listOfMedia, viewedIndex, hasNext, hasPrev);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

- (void)mentionToEvent:(Event*)event recepients:recepients success:(void (^)())onSuccess failure:(void (^)(NSError *error))onFailure
{
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSMutableDictionary* neededDic = [[NSMutableDictionary alloc] init];
    [neededDic setObject:recepients forKey:@"usersId"];
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@events/%@/mentions?access_token=%@", WEEZ_API_DOMAIN, event.objectId, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             onFailure(nil);
         }
         else// success
         {
             onSuccess();
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

#pragma mark -
#pragma mark Group Chat
// Get chat list
- (void)getchatList:(int)page success:(void (^)(BOOL withPages))getChatListSuccess failure:(void (^)(NSError *error))getChatListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    //params
    NSMutableDictionary *neededDic = [[NSMutableDictionary alloc] init];
//    [neededDic setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@home/groups?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the counties request
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             getChatListFailure(nil);
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             // return error code
             getChatListFailure(nil);
         } else// success
         {
             // first page to refresh the result
//             if (page == 0)
//             {
                 messagesList = [[NSMutableArray alloc] init];
//             }
             
             NSMutableArray *messagesResultList = (NSMutableArray*)[responseObject objectForKey:@"groups"];
             //fill in chat messages
             for (NSMutableDictionary *msgObj in messagesResultList)
             {
                 Timeline *message = [[Timeline alloc] init];
                 [message fillWithJSON:msgObj];
                 [messagesList addObject:message];
             }
             // check for new page
             BOOL withNewPage = [[responseObject objectForKey:@"hasNext"]boolValue];
             
             // success result
             getChatListSuccess(withNewPage);
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         getChatListFailure(error);
     }];
}

// Get group list
- (void)getGroupList:(void (^)(NSMutableArray *groupList))getGroupListSuccess failure:(void (^)(NSError *error))getGroupListFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/groups?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager GET:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            getGroupListFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            getGroupListFailure(nil);
        }
        else// success
        {
            // fill in the data
            NSMutableArray *listOfGroups = [[NSMutableArray alloc] init];
            NSMutableArray *resultList = (NSMutableArray*)[responseObject objectForKey:@"groups"];
            // loop all sections
            for (NSMutableDictionary *resultObj in resultList)
            {
                Group *groupObj = [[Group alloc] init];
                [groupObj fillWithJSON:resultObj];
                [listOfGroups addObject:groupObj];
            }
            getGroupListSuccess(listOfGroups);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        getGroupListFailure(error);
    }];
}

// Upload group info
- (void)updateGroup:(Group*)group withImage:(UIImage*)pickedImage success:(void (^)(Group *updatedGroup))updateGroupSuccess failure:(void (^)(NSError *error, int errorCode))updateGroupFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSDictionary* neededDataDic = @{@"name": group.name,@"description" : group.description, @"members": group.members};
    // set group id if exist
    NSString *groupId = @"";
    if ((group.objectId != nil) && ([group.objectId length] > 0))
        groupId = [NSString stringWithFormat:@"/%@", group.objectId];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/groups%@?access_token=%@", WEEZ_API_DOMAIN, groupId, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDataDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
     {
         // image exist
         if (pickedImage != nil)
         {
             double compressionRatio = 1.0;
             UIImage *resizedImage = [[AppManager sharedManager] resizeImage:pickedImage scaledToWidth:IMAGE_PROFILE_DIAMETER];
             NSData *data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
             int round = 0;
             while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
             {
                 compressionRatio = compressionRatio * 0.9;
                 data = UIImageJPEGRepresentation(resizedImage, compressionRatio);
                 round++;
             }
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
             // image exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"image" fileName:fileNameStr mimeType:@"image/jpg"];
         }
     }
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
     }
          success:^(NSURLSessionTask *operation, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             updateGroupFailure(nil, 0);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil)
         {
             updateGroupFailure(nil, 0);
         }
         else// group object
         {
             NSMutableDictionary *resultGroup = (NSMutableDictionary*)[responseObject objectForKey:@"group"];
             Group *groupObj = [[Group alloc] init];
             [groupObj fillWithJSON:resultGroup];
             updateGroupSuccess(groupObj);
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         updateGroupFailure(error, 0);
     }];
}

// Leave group
- (void)leaveGroup:(NSString*)groupId success:(void (^)())leaveGroupSuccess failure:(void (^)(NSError *error))leaveGroupFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed dictionary
    NSDictionary* neededDic = @{@"groupId" : groupId};
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/groups/leave?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            leaveGroupFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            leaveGroupFailure(nil);
        }
        else// success
        {
            leaveGroupSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        leaveGroupFailure(error);
    }];
}

- (void)getGroup:(Group*)group success:(void (^)(Group *group))onSuccess failure:(void (^)(NSError *error))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSDictionary* neededDataDic = @{};
    // set group id if exist
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/groups/%@?access_token=%@", WEEZ_API_DOMAIN, group.objectId, userObject.sessionToken];
    [manager GET:apiLink parameters:neededDataDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             onFailure(nil);
         }
         else{
             // fill user data
             NSDictionary *resultDic = responseObject;
             if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
             {
                 Group *grp = [[Group alloc] init];
                 [grp fillWithJSON:[resultDic objectForKey:@"group"]];
                 grp.messages = [[[grp.messages reverseObjectEnumerator] allObjects]mutableCopy];
                 onSuccess(grp);
             }
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

- (void)getChat:(NSString*)userId success:(void (^)(Group *group))onSuccess failure:(void (^)(NSError *error))onFailure{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // needed data
    NSDictionary* neededDataDic = @{};
    // set group id if exist
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/users/%@?access_token=%@", WEEZ_API_DOMAIN, userId, userObject.sessionToken];
    [manager GET:apiLink parameters:neededDataDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil);
         // check error code
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             onFailure(nil);
         }
         else{
             // fill user data
             NSDictionary *resultDic = responseObject;
             if ((resultDic != nil) && ([[resultDic allKeys] count] > 0))
             {
                 Group *grp = [[Group alloc] init];
                 [grp fillWithJSON:[resultDic objectForKey:@"chat"]];
                 grp.messages = [[[grp.messages reverseObjectEnumerator] allObjects]mutableCopy];
                 onSuccess(grp);
             }
         }
     }
         failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error);
     }];
}

/*! submitting new chat message, could be text message or one of the media mesage types 
 when submitting a custom location this method will create a new location on the api and recal it self with the new locationId
@param group: group could represent a chat between any 2 or more users, so even is peer chat case we will be using groups
@param coordinates: coordinates used to create a location message this type of message contains only coordinates that can be showed on map
@param locationId: optional id of location to attach with the media message currently used only with photo and video messages
@param locationId: when not nil we will create a private location on the api before submitting the message and use the id of the newly created location as locationId */
- (void)sendChatMessage:(NSString *) messsage ToGroup:(Group*)group mediaType:(MediaType) mediaType media:(id) media withFileURL:(NSURL *)fileURL orLocationMessageAt:(CLLocationCoordinate2D) coordinates withLocationId:(NSString*)locationId orCustomLocation:(Location*)customLocation asReplyToMessage:(NSString*)originalMsgId inOriginalGroup:(NSString*)originalGrroupId sharedTimelineId:(NSString*)sharedTimelineId sharedLocationId:(NSString*)sharedLocationId sharedEventId:(NSString*)sharedEventId success:(void (^)())onSuccess failure:(void (^)(NSError *error, NSString *errorMsg))onFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    
    NSMutableDictionary* neededDataDic = [[NSMutableDictionary alloc] init];
    [neededDataDic setObject:group.objectId forKey:@"groups"];
    [neededDataDic setObject:messsage forKey:@"message"];
    [neededDataDic setObject:[NSNumber numberWithInteger:mediaType] forKey:@"type"];
    
    if(originalMsgId && originalGrroupId){
        [neededDataDic setObject:originalMsgId forKey:@"parentId"];
        [neededDataDic setObject:originalGrroupId forKey:@"parentGroupId"];
    }
    
    if(CLLocationCoordinate2DIsValid(coordinates)){
        [neededDataDic setObject:[NSNumber numberWithFloat:coordinates.latitude] forKey:@"lat"];
        [neededDataDic setObject:[NSNumber numberWithFloat:coordinates.longitude] forKey:@"long"];
    }
    
    if(locationId){
        [neededDataDic setObject:locationId forKey:@"locationId"];
    }
    
    if(sharedTimelineId)
        [neededDataDic setObject:sharedTimelineId forKey:@"timelineUser"];
    if(sharedLocationId)
        [neededDataDic setObject:sharedLocationId forKey:@"timelineLocation"];
    if(sharedEventId)
        [neededDataDic setObject:sharedEventId forKey:@"timelineEvent"];
    
    // if private location is defined from map or from google places, create location first then submit message
    if(customLocation){
        [self createLocation:(Location *) customLocation success:^(Location * createdLocation) {
            if(createdLocation){
                [self sendChatMessage:messsage ToGroup:group mediaType:mediaType media:media withFileURL:fileURL orLocationMessageAt:coordinates withLocationId:createdLocation.objectId orCustomLocation:nil asReplyToMessage:originalMsgId inOriginalGroup:originalGrroupId sharedTimelineId:sharedTimelineId sharedLocationId:sharedLocationId sharedEventId:sharedEventId success:onSuccess failure:onFailure];
            }else{
                onFailure(nil, nil);
            }
        } failure:^(NSError *error, int errorCode) {
            onFailure(error, nil);
        }];
        return;
    }

    // set group id if exist
    NSString *groupId = @"";
    if ((group.objectId != nil) && ([group.objectId length] > 0))
        groupId = [NSString stringWithFormat:@"/%@", group.objectId];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSString *apiLink = [NSString stringWithFormat:@"%@chat/send/?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server contact wco
    [manager POST:apiLink parameters:neededDataDic constructingBodyWithBlock:^(id <AFMultipartFormData> formData)
     {
          // image
         if (mediaType == kMediaTypeImage)
         {
             double compressionRatio = 1.0;
             UIImage *pickedImage = (UIImage *) media;
             NSData *data = UIImageJPEGRepresentation(pickedImage, compressionRatio);
             int round = 0;
             while (([data length] > MAX_IMAGE_FILE_SIZE) && (round < 100))
             {
                 compressionRatio = compressionRatio * 0.9;
                 data = UIImageJPEGRepresentation(pickedImage, compressionRatio);
                 round++;
             }
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".jpg"];
             // image exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"media" fileName:fileNameStr mimeType:@"image/jpg"];
         }
         // video case
         else if (mediaType == kMediaTypeVideo)
         {
             NSString *path = [fileURL path];
             NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".mp4"];
             // video exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"media" fileName:fileNameStr mimeType:@"video/mp4"];
         }
         else if (mediaType == kMediaTypeAudio)
         {
             NSString *path = [fileURL path];
             NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
             NSString *fileNameStr = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
             fileNameStr = [fileNameStr stringByReplacingOccurrencesOfString:@"." withString:@"_"];
             fileNameStr = [fileNameStr stringByAppendingString:@".m4a"];
             // video exist
             if (data != nil)
                 [formData appendPartWithFileData:data name:@"media" fileName:fileNameStr mimeType:@"audio/m4a"];
         }
     }
         progress:^(NSProgress * _Nonnull uploadProgress){
             NSLog(@"upload progress %f", uploadProgress.fractionCompleted);
         }
          success:^(NSURLSessionTask *operation, id responseObject)
     {
         // no return object request timeout
         if (responseObject == nil)
             onFailure(nil, nil);
         else if ([responseObject objectForKey:@"error"] != nil){
             // return error code
             onFailure(nil, [responseObject objectForKey:@"error"]);
         }else{
             // store the uploaded media in cache to make sure we dont have to download it
             if([responseObject objectForKey:@"url"]){
                 NSString *url = [responseObject objectForKey:@"url"];
                 SDWebImageManager *manager = [SDWebImageManager sharedManager];
                 if(mediaType == kMediaTypeImage && media)
                     [manager saveImageToCache:media forURL:[NSURL URLWithString:url]];
                 else if(mediaType == kMediaTypeVideo && fileURL){
                     [self saveVideoFromUrl:fileURL toVideoCacheForURL:[NSURL URLWithString:url]];
                 }
             }
             onSuccess();
         }
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
         onFailure(error, nil);
     }];
}

#pragma mark -
#pragma mark Device Functions
// Register device for notificaiton
- (void)registerDeviceForNotification:(NSString*)deviceID success:(void (^)())registerDeviceSuccess failure:(void (^)(NSError *error))registerDeviceFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // device_type 1 for iOS
    NSDictionary* neededDic = @{@"token": deviceID, @"type":@"1"};
    NSString *apiLink = [NSString stringWithFormat:@"%@users/register_device?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
         registerDeviceSuccess();
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
         registerDeviceFailure(error);
    }];
}

#pragma mark -
#pragma mark Signup
/// Sign up register user
- (void)signupRegisterUser:(NSDictionary*)registerInfo success:(void (^)(int resultFlag))signupRegisterUserSuccess failure:(void (^)(NSError *error))signupRegisterUserFailure
{
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    NSDictionary* neededDic = @{@"username":[registerInfo objectForKey:@"username"], @"email":[registerInfo objectForKey:@"email"],
                                @"phoneNumber": [registerInfo objectForKey:@"number"], @"password":[registerInfo objectForKey:@"password"]};
    NSString *apiLink = [NSString stringWithFormat:@"%@users/signup", WEEZ_API_DOMAIN];
    // post the request to server login
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            signupRegisterUserFailure(nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            NSString *errorStr = (NSString*)[responseObject objectForKey:@"error"];
            // invalid username
            if ([errorStr isEqualToString:@"username_email_already_found"])
                signupRegisterUserSuccess(-1);
            else
                signupRegisterUserSuccess(0);
        }
        else// user object
        {
            NSDictionary *resultDic = responseObject;
            userObject = [[User alloc] init];
            [userObject fillWithJSON:resultDic];
            // cach user data and save it in user memeber
            [[AppManager sharedManager] saveUserData:userObject];
            userObject = [[AppManager sharedManager] cachedUserData];
            // return success
            signupRegisterUserSuccess(1);
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        signupRegisterUserFailure(error);
    }];
}

/// Signin login using "email" and "password"
- (void)signinLogin:(NSString*)email andPassword:(NSString*)password success:(void (^)())signupLoginSuccess failure:(void (^)(NSError *error, NSString* errorMsg))signupLoginFailure
{
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // set needed parameters
    NSDictionary* neededDic = @{@"email":email, @"password":password};
    NSString *apiLink = [NSString stringWithFormat:@"%@users/signin", WEEZ_API_DOMAIN];
    // post the request to server
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            signupLoginFailure(nil, nil);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            signupLoginFailure(nil, [responseObject objectForKey:@"error"]);
        }
        else// user object
        {
            NSDictionary *resultDic = responseObject;
            userObject = [[User alloc] init];
            [userObject fillWithJSON:resultDic];
            // cach user data and save it in user memeber
            [[AppManager sharedManager] saveUserData:userObject];
            userObject = [[AppManager sharedManager] cachedUserData];
            signupLoginSuccess();
        }
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        signupLoginFailure(error, nil);
    }];
}

// Resert password using email address
- (void)resetPassword:(NSString*)userEmail withNumber:(NSString*)userNumber success:(void (^)())resetPasswordSuccess failure:(void (^)(NSError *error, int errorCode))resetPasswordFailure
{
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // set needed parameters
    NSDictionary* neededDic = @{@"email":userEmail, @"phoneNumber":userNumber};
    NSString *apiLink = [NSString stringWithFormat:@"%@users/reset_password", WEEZ_API_DOMAIN];
    // post the request to server
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            resetPasswordFailure(nil,1);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            NSString *errorStr = (NSString*)[responseObject objectForKey:@"error"];
            // invalid email
            if ([errorStr isEqualToString:@"no_such_email"])
                resetPasswordFailure(nil,1);
            else// invalid number
                resetPasswordFailure(nil,2);
        }
        else// change password success
            resetPasswordSuccess();
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        resetPasswordFailure(error,0);
    }];
}

// Change password
- (void)changePassword:(NSString*)oldPassword withNewPass:(NSString*)newPassword success:(void (^)())changePasswordSuccess failure:(void (^)(NSError *error, int errorCode))changePasswordFailure
{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // set needed parameters
    NSDictionary* neededDic = @{@"oldPassword":oldPassword, @"newPassword":newPassword};
    NSString *apiLink = [NSString stringWithFormat:@"%@users/change_password?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
    {
        // no return object request timeout
        if (responseObject == nil)
            changePasswordFailure(nil, 0);
        // check error code
        else if ([responseObject objectForKey:@"error"] != nil)
        {
            // return error code
            changePasswordFailure(nil, 1);
        }
        else// change password success
            changePasswordSuccess();
    }
    failure:^(NSURLSessionTask *operation, NSError *error)
    {
        changePasswordFailure(error, 0);
    }];
}

#pragma mark -
#pragma mark Video
// Get video to play
- (void)downloadVideoFromURL:(NSString*)videoLink progress:(void (^)(CGFloat progress))downloadVideoFromURLProgress success:(void (^)(NSURL *filePath))downloadVideoFromURLSuccess failure:(void (^)(NSError *error))downloadVideoFromURLFailure
{
    //Configuring the session manager
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //Most URLs I come across are in string format so to convert them into an NSURL and then instantiate the actual request
    NSURL *formattedURL = [NSURL URLWithString:videoLink];
    NSURLRequest *request = [NSURLRequest requestWithURL:formattedURL];
    //Watch the manager to see how much of the file it's downloaded
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite)
    {
        //Convert totalBytesWritten and totalBytesExpectedToWrite into floats so that percentageCompleted doesn't get rounded to the nearest integer
        CGFloat written = totalBytesWritten;
        CGFloat total = totalBytesExpectedToWrite;
        CGFloat percentageCompleted = written/total;
        //Return the completed progress so we can display it somewhere else in app
        downloadVideoFromURLProgress(percentageCompleted);
    }];
    //Start the download
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
    {
        NSURL *videoURL = [NSURL URLWithString:videoLink];
        NSURL *fullURL = [[AppManager sharedManager] generateLocalVideoURL:videoURL.lastPathComponent];
        //If we already have a video file saved, remove it from the phone
        [[AppManager sharedManager] removeVideoAtPath:fullURL];
        return fullURL;
    }
    completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
    {
        // if there's no error, return the completion block
        if (!error)
            downloadVideoFromURLSuccess(filePath);
        else // otherwise return the error block
            downloadVideoFromURLFailure(error);
    }];
    [downloadTask resume];
}

-(void)saveVideoFromUrl:(NSURL*)originalFileUrl toVideoCacheForURL:(NSURL*)remoteFileUrl{
    NSURL *destinationURL = [[AppManager sharedManager] generateLocalVideoURL:remoteFileUrl.lastPathComponent];
    if ( [[NSFileManager defaultManager] isReadableFileAtPath:[originalFileUrl path]] )
        [[NSFileManager defaultManager] copyItemAtURL:originalFileUrl toURL:destinationURL error:nil];
}


///// ------- loging
- (void)submitLog:(NSString*)logMsg success:(void (^)())onSuccess{
    // user logged out
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    if(!log)
        log = @"";
    log = [NSString stringWithFormat:@"%@ \n %@", log, logMsg];
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // set needed parameters
    NSDictionary* neededDic = @{@"msg":logMsg};
    NSString *apiLink = [NSString stringWithFormat:@"%@home/log/?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         onSuccess();
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
     }];
}
- (void)flushLog{
    if (! [[ConnectionManager sharedManager] isUserLoggedIn])
        return;
    if(!log)
        return;
    
    // init the asynchronase request manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    // set needed parameters
    NSDictionary* neededDic = @{@"msg":[NSString stringWithFormat:@"--- LOG --- \n %@ \n ----------- ", log]};
    NSString *apiLink = [NSString stringWithFormat:@"%@home/log/?access_token=%@", WEEZ_API_DOMAIN, userObject.sessionToken];
    // post the request to server
    [manager POST:apiLink parameters:neededDic progress:nil success:^(NSURLSessionTask *task, id responseObject)
     {
         log = @"";
     }
          failure:^(NSURLSessionTask *operation, NSError *error)
     {
     }];
}

@end
