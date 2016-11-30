//
//  HomeController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "Location.h"
#import "User.h"
#import <SWTableViewCell.h>
#import "IBActionSheet.h"
#import "AppNotification.h"
@import GoogleMaps;

#define kTimelineListTag    0
#define kTimelineGridTag    1


@interface HomeController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate,
                                                SWTableViewCellDelegate, UIGestureRecognizerDelegate, IBActionSheetDelegate>
{
    NSMutableArray *listOfTimelines;
    NSMutableArray *listOfMessages;
    NSMutableArray *listOfLocationsTimelines;
    Timeline *selectedTimeline;
    Timeline *selectedTimelineToViewProfile;
    BOOL isMessagesSectionExist;
    BOOL isTimelinesSectionExist;
    // Header view
    UIImageView *profileImageView;
    UITextField *searchTextField;
    UIView *headerView;
    UIButton *listViewButton;
    UIButton *gridViewButton;
    // Footer view
    UIView *footerView;
    UIButton *recordButton;
    UIButton *searchButton;
    UIButton *notificationButton;
    // Timelines view
    UITableView *timelineTableView;
    UIRefreshControl *tableRefreshControl;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *backgroundButton;
    UIView *loaderView;
    //timelines pagination
    BOOL isMoreTimelines;
    BOOL loadingTimelinesInProgress;
    int currentStoriesPage;
    //messages pagination
    BOOL isMoreMessages;
    BOOL loadingMessagesInProgress;
    int currentMessagesPage;
    //list mode
    int listMode;
    BOOL isSearchMode;
    BOOL isFloatingButtonsVisible;
    /// used to detect scroll direction in table view to show/hide floating buttons
    CGPoint tableViewLastContentOffset;
    // geo location
    CLLocationManager *locationManagr;
    
    //recieved push notification payload
    AppNotification* deepLinkNotification;
}

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mapContainerHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnNotificationsBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *btnSearchBottomConstraint;

// Header view
@property(nonatomic, retain) UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIView *headerView;
@property(nonatomic, retain) IBOutlet UIButton *listViewButton;
@property(nonatomic, retain) IBOutlet UIButton *gridViewButton;
// Footer view
@property(nonatomic, retain) IBOutlet UIView *footerView;
@property(nonatomic, retain) IBOutlet UIButton *recordButton;
@property(nonatomic, retain) IBOutlet UIButton *searchButton;
@property(nonatomic, retain) IBOutlet UIButton *notificationButton;
// Timelines view
@property(nonatomic, retain) IBOutlet UITableView *timelineTableView;
@property(nonatomic, retain) IBOutlet UIView *noResultView;
@property(nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property(nonatomic, retain) IBOutlet UIButton *backgroundButton;
@property(nonatomic, retain) IBOutlet UIView *loaderView;

// handle Notification
- (void)setRecievedDeepLinkingNotification:(AppNotification*)data;
- (void) handlePushNotificationTapEvent;
- (void) hideAllViews;

- (IBAction)listViewAction:(id)sender;
- (IBAction)gridViewAction:(id)sender;
- (IBAction)noResultAction:(id)sender;
- (IBAction)addGroupAction:(id)sender;
- (IBAction)showNotificationsAction:(id)sender;
- (IBAction)startSearchAction;

@end

