//
//  Constants.h
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

/* ---------------------------------------------
 ------------- API Connection ------------------
 -----------------------------------------------
 */
// Facebook image link
#define FACEBOOK_IMAGE_LINK                 @"https://graph.facebook.com/%@/picture?width=240&height=240"

// Default profile picture link
#define PROFILE_DEFAULT_PIC_LINK            @"https://s3-us-west-2.amazonaws.com/weez/profile-pics/default-pic.png"

// Date Formate
#define TIMELINE_DISPLAY_DATE_FORMAT        @"dd.MM.yy HH:mm"
#define EVENT_DISPLAY_DATE_FORMAT           @"dd.MM.yyyy HH:mm"
#define TIMELINE_DISPLAY_TIME_FORMAT        @"HH:mm"
#define OBJECT_UPDATE_DATE_FORMAT           @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define TIMELINE_SHORT_DATE_FORMAT          @"dd.MM.yy"
#define DATE_SERVER_DATES_LOCALE            @"en_US_POSIX"

//Apis Keys
#define PLACES_API_KEY                      @"AIzaSyAUfRYqzIMF7R41ZDRQV9BwffOi2LnusFc"
#define STATIC_MAPS_API_KEY                 @"AIzaSyCFQSE7TVJWsgDhrF9Exn0CCHG5IaK9FQA"

// Server API Calls
#define WEEZ_API_DOMAIN                     @"http://dev.alpha-apps.ae/weez/"
//#define WEEZ_API_DOMAIN                     @"http://192.168.1.13:3000/"

// Notification Center
#define NOTIFICATION_LANGUAGE_CHANGED       @"updatedLanguageChangedNotification"
#define NOTIFICATION_TIMELINE_CHANGED       @"updatedTimelineChangedNotification"

// location
#define PICKED_LOCATION_MAX_DISTANCE       2000.00


#define kSheetNavAction     0
#define kSheetUserActions   1
#define kSheetReportActions 2

#define RANK_BY_CHAT                        @"chat"
#define RANK_BY_MENTION                     @"mention"
#define RANK_BY_BOOST                       @"boost"

/* ---------------------------------------------
 ------------- Caching Files -------------------
 -----------------------------------------------
 */
// User
#define CACH_USER_FOLDER                    @"UserData"
#define CACH_USER_FILE                      @"UserInfo.txt"
#define CACH_LANG_FILE                      @"LanguageInfo.txt"
#define CACH_REPORT_FILE                    @"ReportTypes.txt"
#define CACH_DURATIONS_FILE                 @"imageDurations.txt"
#define CACH_VIDEO_FOLDER                   @"VideoData"


/* ---------------------------------------------
 ------------- Application Interface -----------
 -----------------------------------------------
 */

#define LAYER_CORNER_RADIUS                 4.0
#define PROGRESS_BAR_IMAGE_TAG              999
#define CELL_TIMELINE_LIST_HEIGHT           80
#define CELL_TIMELINE_GRID_HEIGHT           260
#define CELL_LOAD_MORE_HEIGHT               44
#define CELL_USER_HEIGHT                    64
#define CELL_LOCATION_HEIGHT                54
#define CELL_NOTIFICATION_HEIGHT            74
#define CELL_HEADER_HEIGHT                  35
#define CELL_SETTINGS_HEIGHT                44

#define CHAT_ORIGINAL_PREVIEW_HEIGHT        75

#define MAX_VIDEO_LENGTH                    12
#define MAX_AUDIO_LENGTH                    12
#define MAX_IMAGE_FILE_SIZE                 500000
#define IMAGE_PROFILE_DIAMETER              240
#define IMAGE_COVER_HEIGHT                  210
#define IMAGE_IN_CHAT_WIDTH                 400

#define CELL_SWIPE_ACTION_TAG_REPORT        2
#define CELL_SWIPE_ACTION_TAG_LOCATIONS     3
#define CELL_SWIPE_ACTION_TAG_CHAT          4
#define CELL_SWIPE_ACTION_TAG_MORE          5

// Application language
typedef enum
{
    kAppLanguageEN = 0,
    kAppLanguageAR = 1
} AppLanguageType;

// Application colors
typedef enum
{
    kAppColorRed = 0,
    kAppColorGreen = 1,
    kAppColorBlue = 2,
    kAppColorLightGray = 3,
    kAppColorDarkBlue = 4
} AppColorType;

// Application fonts
typedef enum
{
    kAppFontLogo = 0,
    kAppFontTitle = 1,
    kAppFontSubtitle = 2,
    kAppFontDescription = 3,
    kAppFontCellNumber = 4,
    kAppFontCellLargeNumber = 5,
    kAppFontCellTitle = 6,
    kAppFontDescriptionBold = 7,
    kAppFontSubtitleBold = 8
} AppFontType;


/* ---------------------------------------------
 ------------- Enumurated type -----------------
 -----------------------------------------------
 */
// User grant type
typedef enum
{
    kUserGrantTypeFacebook = 0,
    kUserGrantTypePassword = 1
} UserGrantType;

// Notification type
typedef enum
{
    kNotificationTypeFailed = 0,
    kNotificationTypeSuccess = 1,
    kNotificationTypeAlert = 2
} NotificationType;

// Timeline Media type
typedef enum
{
    kMediaTypeImage = 0,
    kMediaTypeVideo = 1,
    kMediaTypeAudio = 2,
    kMediaTypeText = 3,
    kMediaTypeLocation = 4,
    kMediaTypeTimeline = 5 // used in chat messages that references someones else
} MediaType;

// Timeline type
typedef enum
{
    kTimelineTypeUser = 0,
    kTimelineTypeBoost = 1,
    kTimelineTypeMention = 2,
    kTimelineTypeGroup = 3,
    kTimelineTypeChat = 4
} TimelineType;

// Following type
typedef enum
{
    kFollowTypeFollowing = 0,
    kFollowTypeFollowers = 1
} FollowType;

//receiptiants list selection mode
typedef enum{
    SINGLE = 1,
    MULTIPLE = 0
}SELECTION_MODE;

// Location Status
typedef enum
{
    kLocationStatusPending = 0,
    kLocationStatusApproved = 1,
    kLocationStatusRejected = 2
} LocationStatus;

// Media Record operation type
typedef enum
{
    kRecordMediaForTimeline = 0,
    kRecordMediaForChat = 1
} RecordMediaFor;

// Search modes
typedef enum {
    searchModeUsers = 0,
    searchModeLocations = 1,
    searchModeTags = 2
} SearchMode;

// Notificatoins Types
typedef enum {
    kAppNotificationTypeSomeoneMentionedYou = 0,
    kAppNotificationTypeSomeoneStartedFollowingYou = 1,
    kAppNotificationTypeSomeoneAddedYouToGroup = 2,
    kAppNotificationTypeNewMessageInGroup = 3,
    kAppNotificationTypeNewMessageInChat = 4,
    kAppNotificationTypeSomeoneMentionedYouInEvent = 5,
    kAppNotificationTypeSomeoneWantToFollowYou = 6,
    kAppNotificationTypeSomeoneAcceptYourFollowRequest = 7,
} AppNotificationType;

// timelines colletions Types
typedef enum {
    kCollectionTypeLocationTimelines = 0,
    kCollectionTypeTagTimelines = 1,
    kCollectionTypeEventTimelines = 2
} AppCollectionType;

// chat privacy level
typedef enum
{
    kChatPrivacyLevelAll = 0,
    kChatPrivacyLevelFollowers = 1,
    kChatPrivacyLevelFollowersAndFollowing = 2
} AppChatPrivacyLevel;

//top gallery view
typedef enum{
    GALLERY_USERS = 0,
    GALLERY_LOACTIONS = 1,
    GALLERY_TAGS = 2,
} GALLERY_TYPE;

//API Errors
typedef enum{
    ERROR_PRIVECY = 0
} API_ERROR;

typedef enum{
    NOT_FOLLOWING = 0,//default state he can follow me or send me a request if my account is private
    REQUESTED = 1,//he send me a request but didn't check yet
    FOLLOWING = 2//he is following me
} FOLLOWING_STATE;

typedef enum{
NOT_FOLLOWER = 0,// I didn't follow him but can follow or send request..
PENDING = 1,// I sent him a request but didn't check yet
FOLLOWER = 2//I am following him
} FOLLOWER_STATE;

#endif