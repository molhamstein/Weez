//
//  HomeController.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "HomeController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"
#import "TimelineMapCell.h"
#import "TimelineListCell.h"
#import "TimelineChatListCell.h"
#import "TimelineGridCell.h"
#import "TimelineController.h"
#import "TimelineChatGridCell.h"
#import "AppDelegate.h"
#import "ProfileController.h"
#import "GroupDetailsController.h"
#import "ChatController.h"
#import "UserRelatedLocationsController.h"
#import "ReportType.h"
#import "NotificationsListController.h"
#import "TimelinesCollectionController.h"
#import "TimelineHeaderCell.h"

@implementation HomeController

// Header view
@synthesize profileImageView;
@synthesize headerView;
@synthesize listViewButton;
@synthesize gridViewButton;

// Footer view
@synthesize footerView;
@synthesize recordButton;
@synthesize searchButton;
@synthesize notificationButton;
// Timelines view
@synthesize timelineTableView;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure view
    [self configureView];
    // init timelines array
    listOfTimelines = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] timelinesList]];
    listOfMessages = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] messagesList]];
    isMessagesSectionExist = [listOfMessages count] > 0;
    isTimelinesSectionExist = [listOfTimelines count] > 0;
    //timelines paging
    loadingTimelinesInProgress = NO;
    isMoreTimelines = YES;
    currentStoriesPage = 0;
    //mesasges paging
    loadingMessagesInProgress = NO;
    isMoreMessages = NO;
    currentMessagesPage = 0;
    //init views
    [noResultView setHidden:YES];
    isSearchMode = NO;
    [backgroundButton setHidden:YES];
    selectedTimeline = [[Timeline alloc] init];
    [self listViewAction:nil];
    [self refreshTable];
    // register for new updates on user status
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_LANGUAGE_CHANGED object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         dispatch_async(dispatch_get_main_queue(),^{
             [timelineTableView reloadData];
         });
     }];
    // register for new updates on user status
    [[NSNotificationCenter defaultCenter] addObserverForName:NOTIFICATION_TIMELINE_CHANGED object:nil queue:nil usingBlock:^(NSNotification *note)
     {
         dispatch_async(dispatch_get_main_queue(),^{
             [self refreshTable];
             [self reloadMapAnnotations];
         });
     }];
    // register for remote notification
    [[AppDelegate sharedDelegate] changeRemoteNotification];
    
    // init locatoin manager and check permissions
    locationManagr = [[CLLocationManager alloc] init];
    locationManagr.delegate = self;
    locationManagr.distanceFilter = kCLDistanceFilterNone; //whenever we move
    locationManagr.desiredAccuracy = kCLLocationAccuracyBest;
    //locationManagr.distanceFilter = 300;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManagr requestWhenInUseAuthorization];
    }else{
        [locationManagr requestLocation];
    }
    if(deepLinkNotification){
        [self handlePushNotificationTapEvent];
    }
    
    //add swipe guesture recognizer
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    //[self.view addGestureRecognizer:swipeleft];
}

// View will appear
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[AppManager sharedManager] setNavigationBarStyle];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:timelineTableView];
    [[AppManager sharedManager] flipViewDirection:headerView];
    [self configureSearchMode];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // refresh current user
    [[ConnectionManager sharedManager] getCurrentUser:^
     {
     }
                                              failure:^(NSError *error)
     {
     }];
}

// Configure view controls
- (void)configureView
{
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // add refresh table control
    tableRefreshControl = [[UIRefreshControl alloc] init];
    [tableRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [timelineTableView addSubview:tableRefreshControl];
    // add footer view
    /*CAGradientLayer *gradient = [CAGradientLayer layer];
     gradient.frame = footerView.bounds;
     gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
     [footerView.layer insertSublayer:gradient atIndex:0];*/
    //    [recordButton.layer setShadowOffset:CGSizeMake(0, 0)];
    //    [recordButton.layer setShadowRadius:8.0];
    //    [recordButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    //    [recordButton.layer setShadowOpacity:0.4];
    
    //    [searchButton.layer setShadowOffset:CGSizeMake(0, 0)];
    //    [searchButton.layer setShadowRadius:5.0];
    //    [searchButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    //    [searchButton.layer setShadowOpacity:0.2];
    //
    //    [notificationButton.layer setShadowOffset:CGSizeMake(0, 0)];
    //    [notificationButton.layer setShadowRadius:5.0];
    //    [notificationButton.layer setShadowColor:[[UIColor blackColor] CGColor]];
    //    [notificationButton.layer setShadowOpacity:0.2];
}

//TODO Clean Search from Home Screen
// Configure search mode
- (void)configureSearchMode
{
    // set font
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"HOME_NO_TIMELINES"];
    // normal mode
    if (! isSearchMode)
    {
        // back button
        UIButton *searchNavButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        searchNavButton.frame = CGRectMake(0, 0, 20, 20);
        [searchNavButton setBackgroundImage:[UIImage imageNamed:@"homeAddGroup"] forState:UIControlStateNormal];
        [searchNavButton addTarget:self action:@selector(showNavActionsSheetAction:) forControlEvents:UIControlEventTouchUpInside];
        // Initialize UIBarbuttonitem
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:searchNavButton];
        self.navigationItem.leftBarButtonItem = barButton;
        // profile button
        UIButton *profileButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        profileButton.frame = CGRectMake(0, 0, 32, 32);
        [profileButton addTarget:self action:@selector(profileAction) forControlEvents:UIControlEventTouchUpInside];
        UIView *profileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [profileView addSubview:profileButton];
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        HomeController __weak *weakSelf = self;
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:[[ConnectionManager sharedManager] userObject].profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
         }];
        [profileView addSubview:profileImageView];
        // Initialize UIBarbuttonitem
        UIBarButtonItem *fixedSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSeperator.width = -6;
        UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:profileView];
        self.navigationItem.rightBarButtonItems = @[fixedSeperator, barButton2];
        // set text
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_HOME_TITLE"];
        self.navigationItem.titleView = nil;
        //        UIImage *image = [UIImage imageNamed:@"navLogo"];
        //        UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        //        titleImg.contentMode = UIViewContentModeScaleAspectFit;
        //        titleImg.image = image;
        //        self.navigationItem.titleView = titleImg;
    }
    //    else// search mode
    //    {
    //        // close button
    //        UIButton *closeButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    //        closeButton.frame = CGRectMake(0, 0, 12, 12);
    //        [closeButton setBackgroundImage:[UIImage imageNamed:@"navCloseIcon"] forState:UIControlStateNormal];
    //        [closeButton addTarget:self action:@selector(endSearchAction) forControlEvents:UIControlEventTouchUpInside];
    //        // Initialize UIBarbuttonitem
    //        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    //        self.navigationItem.rightBarButtonItems = @[];
    //        self.navigationItem.rightBarButtonItem = barButton;
    //        self.navigationItem.leftBarButtonItems = nil;
    //        // add search field to the navigation bar
    //        int offset = 44;
    //        // search bar view
    //        UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, self.view.frame.size.width-offset, 28)];
    //        searchBarView.backgroundColor = [UIColor clearColor];
    //        // search field
    //        searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, searchBarView.frame.size.width, searchBarView.frame.size.height)];
    //        searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"HOME_SEARCH_PLACEHOLDER"];
    //        UIColor *placeholderColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    //        [searchTextField setValue:placeholderColor forKeyPath:@"_placeholderLabel.textColor"];
    //        searchTextField.textColor = [UIColor whiteColor];
    //        searchTextField.backgroundColor = [UIColor clearColor];
    //        searchTextField.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    //        searchTextField.textAlignment = NSTextAlignmentLeft;
    //        searchTextField.returnKeyType = UIReturnKeySearch;
    //        searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    //        searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //        searchTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    //        searchTextField.delegate = self;
    //        [searchTextField becomeFirstResponder];
    //        // set search bar
    //        [searchBarView addSubview:searchTextField];
    //        self.navigationItem.titleView = searchBarView;
    //        self.navigationItem.title = @"";
    //        // flip search bar
    //        [[AppManager sharedManager] flipViewDirection:searchBarView];
    //    }
}

// Start search action
- (IBAction)startSearchAction
{
    [self performSegueWithIdentifier:@"homeAddFriendSegue" sender:self];
    //    isSearchMode = YES;
    //    searchTextField.text = @"";
    //    [self configureSearchMode];
}

// End search action
- (void)endSearchAction
{
    isSearchMode = NO;
    // hide keyboard
    [searchTextField resignFirstResponder];
    [self configureSearchMode];
    [self loadTimelinesWithPage:0];
}

// Profile action
- (void)profileAction
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    [tableRefreshControl endRefreshing];
    [self performSegueWithIdentifier:@"homeProfileSegue" sender:self];
}

- (void)profileActionWithUser:(UIButton*)sender{
    
    int rowIndex = (int)sender.tag;
    int section = (int)sender.imageView.tag;
    if(isMessagesSectionExist && section ==1)
        selectedTimelineToViewProfile = [listOfMessages objectAtIndex:rowIndex];
    else
        selectedTimelineToViewProfile = [listOfTimelines objectAtIndex:rowIndex];
    [tableRefreshControl endRefreshing];
    [self performSegueWithIdentifier:@"homeProfileSegue" sender:self];
}

- (void)showTimelineForSenderButton:(UIButton*)sender{
    
    int rowIndex = (int)sender.tag;
    selectedTimeline = [listOfTimelines objectAtIndex:rowIndex];
    // group or chat cell
    if (selectedTimeline.timelineType != kTimelineTypeGroup){
        if(selectedTimeline.mediaDuration != 0)
            [self performSegueWithIdentifier:@"homeTimelineSegue" sender:self];
    }else
        [self performSegueWithIdentifier:@"homeChatSegue" sender:self];
}

- (void)userRelatedLocationsAction:(UIButton*)sender{
    int rowIndex = (int)sender.tag;
    [self userRelatedLocationsActionWithIndex:rowIndex];
}

- (void)userRelatedLocationsActionWithIndex:(int)timelineIndex{
    selectedTimelineToViewProfile = [listOfTimelines objectAtIndex:timelineIndex];
    [self performSegueWithIdentifier:@"homeUserRelatedLocationsSegue" sender:self];
}



// List view action
- (IBAction)listViewAction:(id)sender
{
    [listViewButton setSelected:YES];
    [gridViewButton setSelected:NO];
    // change view mode
    listMode = kTimelineListTag;
    [timelineTableView reloadData];
}

// Grid view action
- (IBAction)gridViewAction:(id)sender
{
    [listViewButton setSelected:NO];
    [gridViewButton setSelected:YES];
    // change view mode
    listMode = kTimelineGridTag;
    [timelineTableView reloadData];
}

// No result action
- (IBAction)noResultAction:(id)sender
{
    // not search mode
    if (!isSearchMode)
    {
        [self refreshTable];
        [self reloadMapAnnotations];
    }
}

// Add group action
- (IBAction)addGroupAction:(id)sender
{
    [self performSegueWithIdentifier:@"homeAddGroupSegue" sender:self];
}

- (IBAction)showNotificationsAction:(id)sender
{
    [self performSegueWithIdentifier:@"homeNotificationsListSegue" sender:self];
}

- (IBAction)showNavActionsSheetAction:(id)sender{
    // action sheet options
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList = @[[[AppManager sharedManager] getLocalizedString:@"HOME_ACTIONS_CREATE_GRP"],
                            [[AppManager sharedManager] getLocalizedString:@"HOME_ACTIONS_ADD_FRIEND"]
                            ];
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:2];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:0];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:1];
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:2];
    // add images
    NSArray *buttonsArray = [actionOptions buttons];
    UIButton *btnFacebook = [buttonsArray objectAtIndex:0];
    [btnFacebook setImage:[UIImage imageNamed:@"createNewGroup"] forState:UIControlStateNormal];
    btnFacebook.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnFacebook.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnTwitter = [buttonsArray objectAtIndex:1];
    [btnTwitter setImage:[UIImage imageNamed:@"addNewFriend"] forState:UIControlStateNormal];
    btnTwitter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTwitter.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnTwitter.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    actionOptions.tag = kSheetNavAction;
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}

- (IBAction)showUserActionsSheetAction:(Timeline*)timeline{
    
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList;
    
    NSString *followString = [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_FOLLOW"] ;
    if([timeline amAskingForFollow])
        followString = [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_CANCEL_FOLLOW_REQUEST"];
    else if ([timeline isFollowing])
        followString = [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_UNFOLLOW"];
    
    
    actionList = @[[[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_LOCATIONS"],
                    followString,
                    [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_REPORT"]
                    ];
    
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:3];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:0];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:1];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:2];
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:3];
    // add images
    NSArray *buttonsArray = [actionOptions buttons];
    
    UIButton *btn1 = [buttonsArray objectAtIndex:0];
    [btn1 setImage:[UIImage imageNamed:@"actionUserLocations"] forState:UIControlStateNormal];
    btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn1.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btn1.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    UIButton *btn2 = [buttonsArray objectAtIndex:1];
    if([timeline isFollowing])
        [btn2 setImage:[UIImage imageNamed:@"actionUserFollow"] forState:UIControlStateNormal];
    else
        [btn2 setImage:[UIImage imageNamed:@"actionUserFollow"] forState:UIControlStateNormal];
    btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn2.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btn2.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    UIButton *btn3 = [buttonsArray objectAtIndex:2];
    [btn3 setImage:[UIImage imageNamed:@"actionUserReport"] forState:UIControlStateNormal];
    btn3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn3.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btn3.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    actionOptions.tag = kSheetUserActions;
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}

- (IBAction)showReportTypesSheetAction:(Timeline*)timeline{
    
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSMutableArray *actionList = [[NSMutableArray alloc] init];
    NSMutableArray *reportTypes = [ConnectionManager sharedManager].reportTypes;
    if(!reportTypes || [reportTypes count] <= 0)
        return;
    
    for (ReportType *report in reportTypes) {
        [actionList addObject:report.msg];
    }
    
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:[reportTypes count]];
    
    for (int i = 0; i < [reportTypes count]; i++) {
        [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:i];
    }
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:[reportTypes count]];
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    actionOptions.tag = kSheetReportActions;
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}


#pragma mark -
#pragma mark Actions Sheet
// Action sheet pressed button
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kSheetNavAction){
        if (buttonIndex == 0){
            [self addGroupAction:nil];
        }else if (buttonIndex == 1){ // AddFriendAction
            [self startSearchAction];
        }
    }else if(actionSheet.tag == kSheetUserActions){
        if (buttonIndex == 0){ // user related locations
            selectedTimelineToViewProfile = selectedTimeline;
            selectedTimeline = nil;
            [self performSegueWithIdentifier:@"homeUserRelatedLocationsSegue" sender:self];
        }else if (buttonIndex == 1){ // follow
            [self followActionUser:selectedTimeline.userId WithPrivateProfile:selectedTimeline.isPrivate];
            selectedTimeline = nil;
        }else if(buttonIndex == 2){
            [self showReportTypesSheetAction:selectedTimeline];
        }
    }else if(actionSheet.tag == kSheetReportActions){
        if(buttonIndex < [[ConnectionManager sharedManager].reportTypes count]){
            ReportType *report = [[ConnectionManager sharedManager].reportTypes objectAtIndex:buttonIndex];
            [[ConnectionManager sharedManager] reportUser:selectedTimeline.userId reportType:report.type success:^{
                [[AppManager sharedManager] showNotification:@"MSG_REPORTED_SUCCESS" withType:kNotificationTypeSuccess];
            } failure:^(NSError *error) {
                [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
            }];
        }
        selectedTimeline = nil;
    }
}


#pragma mark -
#pragma mark Map
// Reload map annotations
- (void)reloadMapAnnotations{
    for (UITableViewCell *cell in [timelineTableView visibleCells])
    {
        if([cell isKindOfClass:[TimelineMapCell class]]) {
            TimelineMapCell * headerCell = (TimelineMapCell *)cell;
            [headerCell reloadMapAnnotaions:listOfLocationsTimelines];
        }
    }
}


#pragma mark location tracking -
#pragma mark Location Tracking
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        [locationManagr requestLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"location falure %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    //NSLog(@"lat:%f, lon:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [AppManager sharedManager].currenttUserLocation = newLocation;
    [self loadTimelinesWithPage:0];
    //[locationManagr stopUpdatingLocation];
}

#pragma mark-
#pragma mark TableView
// Refresh table view with tableRefreshControl
- (void)refreshTable
{
    // no in search mode
    if (! isSearchMode)
    {
        [self loadTimelinesWithPage:0];
    }
    else // end refreshing
        [tableRefreshControl endRefreshing];
}

// Load timelines (stories) with page number
- (void)loadTimelinesWithPage:(int)page
{
    loadingTimelinesInProgress = YES;
    // start animation
    if (!isTimelinesSectionExist && !isMessagesSectionExist)
    {
        [loaderView setHidden:NO];
        [noResultView setHidden:NO];
    }
    // get products list
    [[ConnectionManager sharedManager] getTimelinesList:page lattitude:[AppManager sharedManager].currenttUserLocation.coordinate.latitude longitude:[AppManager sharedManager].currenttUserLocation.coordinate.longitude success:^(BOOL withPages)
     {
         // end refreshing
         [tableRefreshControl endRefreshing];
         [loaderView setHidden:YES];
         loadingTimelinesInProgress = NO;
         isMoreTimelines = withPages;
         
         // fill in data
         listOfTimelines = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] timelinesList]];
         isTimelinesSectionExist = [listOfTimelines count] > 0;
         
         listOfMessages = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] topMessagesList]];
         isMessagesSectionExist = [listOfMessages count] > 0;
         isMoreMessages = [listOfMessages count] > 2;
         
         // reload table view
         if (isMessagesSectionExist || isTimelinesSectionExist)
         {
             // show list
             [timelineTableView reloadData];
             [noResultView setHidden:YES];
             // increase page
             currentStoriesPage = page;
         }
         else// no result
         {
             [noResultView setHidden:NO];
         }
         
         // refresh header map
         listOfLocationsTimelines = [ConnectionManager sharedManager].timelinesLocationsList;
         [self reloadMapAnnotations];
     }
                                                failure:^(NSError *error)
     {
         // end refreshing
         [tableRefreshControl endRefreshing];
         [loaderView setHidden:YES];
         loadingTimelinesInProgress = NO;
         isMoreTimelines = NO;
         
         // reload table view
         if ([listOfTimelines count] > 0)
         {
             // show list
             [timelineTableView reloadData];
             [noResultView setHidden:YES];
             // alert user for no internet
             if (page == 0)
             {
                 // show notification error
                 [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
             }
         }
         else// no result
         {
             [noResultView setHidden:NO];
         }
     }];
}

// Search
- (void)search:(NSString*)keywords
{
    // start loading
    [loaderView setHidden:NO];
    [searchTextField setEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    [noResultView setHidden:YES];
    // prepare lists and clear data
    listOfTimelines = [[NSMutableArray alloc] init];
    // search keywords
    [[ConnectionManager sharedManager] searchForTimeline:keywords success:^(NSMutableArray *timlineList)
     {
         // stop loader
         [self.view setUserInteractionEnabled:YES];
         [loaderView setHidden:YES];
         [searchTextField setEnabled:YES];
         // fill in data
         listOfTimelines = [[NSMutableArray alloc] initWithArray:timlineList];
         isTimelinesSectionExist = [listOfTimelines count] > 0;
         // reload table
         [timelineTableView reloadData];
         [timelineTableView setContentOffset:CGPointZero animated:YES];
         // no result
         if ([listOfTimelines count] == 0)
         {
             [noResultView setHidden:NO];
         }
     }
                                                 failure:^(NSError *error)
     {
         // stop loader
         [self.view setUserInteractionEnabled:YES];
         [loaderView setHidden:YES];
         [searchTextField setEnabled:YES];
         // show notification error
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
     }];
}



// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // Unregister from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Table view data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numberOfSections = 1;//Map section
    if(isMessagesSectionExist)
        numberOfSections++;
    if(isTimelinesSectionExist)
        numberOfSections++;
    
    return numberOfSections;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)//map section
    {
        return 0.01f;
    }
    else
    {
        return 30.0f;
    }
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TimelineHeaderCell *header = (TimelineHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"timelineHeaderCell"];
    NSString *title = [[AppManager sharedManager]getLocalizedString:@"HOME_SECTION_STORIES"];
    if(isMessagesSectionExist && section == 1)
        title = [[AppManager sharedManager]getLocalizedString:@"HOME_SECTION_MESSAGES"];
    
    [header setTitle:title];
    return header;
}

// Footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0 )//Map Section footer View
        return 0.01f;
    
    if(isMessagesSectionExist && section ==1 && isMoreMessages)//Message section show more height
       return 44;
    
    BOOL inTimelinesSection = (isMessagesSectionExist && section == 2) || (!isMessagesSectionExist && section == 1);
    
    if(isMoreTimelines && inTimelinesSection)
        return 44;
    
    return 0.01f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if(isMessagesSectionExist && section ==1 && isMoreMessages)
    {
        UIButton *loadMoreButton=[UIButton buttonWithType:UIButtonTypeCustom];
        NSString *more = [[AppManager sharedManager] getLocalizedString:@"HOME_SECTION_SHOW_MORE"];
        NSMutableAttributedString *moreUnderlined = [[NSMutableAttributedString alloc] initWithString:more];
        NSRange range = NSMakeRange(0, [moreUnderlined length]);
        [moreUnderlined addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
        [moreUnderlined addAttribute: NSForegroundColorAttributeName value:[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f] range: range];
        [loadMoreButton setAttributedTitle:moreUnderlined forState:UIControlStateNormal];
        [loadMoreButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontCellNumber]];
        loadMoreButton.frame=CGRectMake(tableView.frame.size.width/2, 44, tableView.frame.size.width, 40);
        [loadMoreButton setBackgroundColor:[UIColor whiteColor]];
        //load more action
        [loadMoreButton addTarget:self action:@selector(loadMoreMessages:) forControlEvents:UIControlEventTouchUpInside];
        return loadMoreButton;
    }
    else if(section == 0 || !isMoreTimelines || !isMoreMessages)
    {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        //Add loader
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(tableView.frame.size.width/2, 44, 44, 44);
    [activityIndicator startAnimating];
        return activityIndicator;
    }
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if (listMode == kTimelineListTag)//Map Section only at the list mode
            return 140.0f;
        return 0.01f;
    }
    // grid cell
    if (listMode == kTimelineGridTag)
        return CELL_TIMELINE_GRID_HEIGHT;
    // normal cell
    return CELL_TIMELINE_LIST_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)//map cell
        return 1;
    NSInteger numberOfRows = 0;
    if(isMessagesSectionExist && section == 1)
    {
        numberOfRows = [listOfMessages count];
    }
    else if(isTimelinesSectionExist)
    {
        numberOfRows = [listOfTimelines count];
    }
    return numberOfRows;
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"timelineListCell";
    static NSString *CellIdentifier3 = @"timelineGridCell";
    static NSString *CellIdentifier4 = @"timelineChatListCell";
    static NSString *CellIdentifier5 = @"timelineChatGridCell";
    static NSString *CellIdentifier6 = @"TimelineMapCell";
    
    if (indexPath.section == 0)//Map section
    {
        TimelineMapCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier6];
        [cell initMap];
        [cell reloadMapAnnotaions:listOfLocationsTimelines];
        return cell;
    }
    
    // list cell
    if (listMode == kTimelineListTag)
    {
        Timeline *timelineObj;
        //Messages section chat cell
        if(isMessagesSectionExist && indexPath.section == 1)
        {
            TimelineChatListCell * cell = (TimelineChatListCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
            timelineObj = [listOfMessages
                           objectAtIndex:indexPath.row];
            [cell populateCellWithContent:timelineObj];
            [cell initSwipeActions:self];
            // open profile button
            cell.profileButton.tag = indexPath.row;
            cell.profileButton.imageView.tag = indexPath.section;
            
            if(timelineObj.timelineType != kTimelineTypeGroup){
                [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                cell.profileButton.hidden = NO;
            }else{
                [cell.profileButton removeTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                cell.profileButton.hidden = YES; // hide btn to enable cell click
            }
            return cell;
        }
        else
        {
            // timeline list cell
            TimelineListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
            timelineObj = [listOfTimelines objectAtIndex:indexPath.row];
            [cell populateCellWithContent:timelineObj];
            
            // open profile button
            cell.profileButton.tag = indexPath.row;
            cell.profileButton.imageView.tag = indexPath.section;
            cell.mediaButton.tag = indexPath.row;
            if(timelineObj.timelineType != kTimelineTypeGroup){
                [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                [cell.mediaButton addTarget:self action:@selector(showTimelineForSenderButton:) forControlEvents:UIControlEventTouchUpInside];
                cell.mediaButton.hidden = NO;
                cell.profileButton.hidden = NO;
            }else{
                [cell.profileButton removeTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                [cell.mediaButton removeTarget:self action:@selector(showTimelineForSenderButton:) forControlEvents:UIControlEventTouchUpInside];
                cell.mediaButton.hidden = YES; // hide btn to enable cell click
                cell.profileButton.hidden = YES; // hide btn to enable cell click
            }
            
            // user related locations button
            cell.locationsButton.tag = indexPath.row;
            if(timelineObj.timelineType != kTimelineTypeGroup)
                [cell.locationsButton addTarget:self action:@selector(userRelatedLocationsAction:) forControlEvents:UIControlEventTouchUpInside];
            else
                [cell.locationsButton removeTarget:self action:@selector(userRelatedLocationsAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // swipe cell
            [cell initSwipeActions:self];
            return cell;
        }
    }
    else// grid cell
    {
        // instagram messages
        if(isMessagesSectionExist && indexPath.section == 1)//if(timelineObj.timelineType == kTimelineTypeGroup)
        {
            Timeline *timelineObj = [listOfMessages objectAtIndex:indexPath.row];
            // timeline grid cell
            TimelineChatGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier5 forIndexPath:indexPath];
            [cell populateCellWithContent:timelineObj];
            // swipe cell
            [cell initSwipeActions:self];
            
            
            if(timelineObj.timelineType != kTimelineTypeGroup){
                [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                cell.profileButton.hidden = NO;
            }else{
                [cell.profileButton removeTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
                cell.profileButton.hidden = YES; // hide btn to enable cell click
            }
            // open profile button
            cell.profileButton.tag = indexPath.row;
            cell.profileButton.imageView.tag = indexPath.section;
            return cell;
        }
        else// instagram stories
        {
            Timeline *timelineObj = [listOfTimelines objectAtIndex:indexPath.row];
            // timeline grid cell
            TimelineGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            [cell populateCellWithContent:timelineObj];
            // remove previous progress bar
            for (UIImageView *img in cell.contentView.subviews)
            {
                if ([img isKindOfClass:[UIImageView class]] && img.tag == PROGRESS_BAR_IMAGE_TAG)
                    [img removeFromSuperview];
            }
            // set viewed percentage
            int maxWidth = self.view.frame.size.width;
            float progressWidth = (float)maxWidth * (float)timelineObj.viewedPercentage / 100.0;
            cell.progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.thumbnailView.frame.origin.y + cell.thumbnailView.frame.size.height - 3, progressWidth, 3)];
            cell.progressImageView.tag = PROGRESS_BAR_IMAGE_TAG;
            cell.progressImageView.backgroundColor = [[AppManager sharedManager] getColorType:kAppColorRed];
            cell.progressImageView.clipsToBounds = YES;
            cell.progressImageView.layer.cornerRadius = 1.5;
            [cell.contentView addSubview:cell.progressImageView];
            
            // open profile button
            cell.profileButton.tag = indexPath.row;
            cell.profileButton.imageView.tag = indexPath.section;
            cell.mediaButton.tag = indexPath.row;
            [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.mediaButton addTarget:self action:@selector(showTimelineForSenderButton:) forControlEvents:UIControlEventTouchUpInside];
            // user related locations button
            cell.locationsButton.tag = indexPath.row;
            [cell.locationsButton addTarget:self action:@selector(userRelatedLocationsAction:) forControlEvents:UIControlEventTouchUpInside];
            
            // swipe cell
            [cell initSwipeActions:self];
            return cell;
        }
    }
}


// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)//map section
    {
        return;
    }
    if(isMessagesSectionExist && indexPath.section == 1)
        selectedTimeline = [listOfMessages objectAtIndex:indexPath.row];
    else
        selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
    
    if(selectedTimeline.canChat){
        [self performSegueWithIdentifier:@"homeChatSegue" sender:self];
    }else{
        selectedTimeline = nil;
    }
    // deselect row for next touch
    [timelineTableView deselectRowAtIndexPath:indexPath animated:NO];
}

// Will display cell at index
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionsCount = [tableView numberOfSections];
    NSInteger rowsCount = [tableView numberOfRowsInSection:[indexPath section]];
    // This is the last cell in the table
    if ([indexPath section] == sectionsCount - 1 && [indexPath row] == rowsCount - 1) {
        //check if in timeline section
        if(isTimelinesSectionExist && isMoreTimelines)
        {
            // loading process
            if (!loadingTimelinesInProgress && !isSearchMode)
                [self loadTimelinesWithPage:currentStoriesPage + 1];// load more data
        }
    }
}

-(void)loadMoreMessages :(id) sender
{
    [self performSegueWithIdentifier:@"homeMessagesListSegue" sender:sender];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint currentOffset = scrollView.contentOffset;
    if (currentOffset.y > tableViewLastContentOffset.y){
        [self showFloatingButtons:YES];
    }
    else{
        [self showFloatingButtons:NO];
    }
    tableViewLastContentOffset = currentOffset;
}

#pragma mark -
#pragma mark delete chat cell
-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.timelineTableView];
    
    NSIndexPath *indexPath = [self.timelineTableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil){//stop deletion mode after tapping out of the collection cells
        NSLog(@"couldn't find index path");
    } else {
        if(isMessagesSectionExist && indexPath.section == 1)
        {
            [self deleteCell:indexPath];
        }
        
    }
}

-(void) deleteCell :(NSIndexPath*)indexpath
{
    [listOfMessages removeObjectAtIndex:indexpath.row];
    isMessagesSectionExist = [listOfMessages count] > 0;
    if(isMessagesSectionExist)//delete row
    {
        [timelineTableView deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else//delete last row by remove the Messages section
    {
        [self.timelineTableView beginUpdates];
        [self.timelineTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.timelineTableView endUpdates];
    }
    //check if the deleted row was the last one at the table
    if(!isMessagesSectionExist && !isTimelinesSectionExist)
    {
        [noResultView setHidden:NO];
    }
    [timelineTableView reloadData];
    
}

#pragma mark -
#pragma mark SWTableViewCellDelegate
// Scrolling state
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    //    // right swipe
    //    if (state == kCellStateRight){
    //        NSIndexPath *indexPath = [timelineTableView indexPathForCell:cell];
    //        selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
    //        [self performSegueWithIdentifier:@"homeChatSegue" sender:self];
    //        [cell hideUtilityButtonsAnimated:YES];
    //    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath *indexPath = [timelineTableView indexPathForCell:cell];
    UIButton *btn = [[cell rightUtilityButtons] objectAtIndex:index];
    NSInteger tag = btn.tag;
    //get selected timeline
    if(isMessagesSectionExist && indexPath.section ==1)
        selectedTimeline = [listOfMessages objectAtIndex:indexPath.row];
    else
        selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
    
    // comment to dania
    // you should apply the same cases in TimelinesCollectionController
    switch (tag) {
        case CELL_SWIPE_ACTION_TAG_CHAT:
            // Comment to dania
            // dont remove this case as its still used in group cell
            [self performSegueWithIdentifier:@"homeChatSegue" sender:self];
            break;
        case CELL_SWIPE_ACTION_TAG_REPORT:
            // report
            break;
        case CELL_SWIPE_ACTION_TAG_LOCATIONS:
            [self userRelatedLocationsActionWithIndex:(int)indexPath.row];
            break;
        case CELL_SWIPE_ACTION_TAG_MORE:
            [self showUserActionsSheetAction:selectedTimeline];
            break;
    }
    [cell hideUtilityButtonsAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark -
#pragma mark Map collapse on scroll
- (void)didSwiepeTable:(UIPanGestureRecognizer*)gestureRecognizer {
}



- (void) showFloatingButtons:(BOOL) show
{
    if(show){
        self.btnNotificationsBottomConstraint.constant = 10;
        self.btnSearchBottomConstraint.constant = 10;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }
                         completion:^(BOOL finished)
         {
             isFloatingButtonsVisible = YES;
         }];
        
    }else{
        self.btnNotificationsBottomConstraint.constant = -120;
        self.btnSearchBottomConstraint.constant = -120;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }
                         completion:^(BOOL finished)
         {
             isFloatingButtonsVisible = NO;
         }];
    }
}

// Follow user
-(IBAction)followActionUser:(NSString*)userId WithPrivateProfile:(BOOL) isPrivate{
    [[ConnectionManager sharedManager].userObject followFriend:userId];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:userId success:^(void){
        // notify about timeline changes
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
    }
                                          failure:^(NSError * error)
     {
     }];
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // search for content
    if ([textField.text length] > 0)
        [self search:textField.text];
    [textField resignFirstResponder];
    [AppManager sharedManager].activeField = nil;
    return YES;
}

// Start typing in text field
- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [backgroundButton setHidden:NO];
    // set active field
    [AppManager sharedManager].activeField = textField;
}

// End typing in text field
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [backgroundButton setHidden:YES];
    [AppManager sharedManager].activeField = nil;
    // end search
    if ([textField.text length] == 0)
        [self endSearchAction];
}

// Background click
- (IBAction)backgroundClick:(id)sender
{
    // hide keyboard
    [searchTextField resignFirstResponder];
    [backgroundButton setHidden:YES];
    [AppManager sharedManager].activeField = nil;
}

#pragma mark -
#pragma mark Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // timeline details
    if ([[segue identifier] isEqualToString:@"homeTimelineSegue"]){
        TimelineController *timelineController = segue.destinationViewController;
        //handle tapping on push notification that's says someone mention you
        if([sender isKindOfClass:[AppNotification class]])
        {
            [timelineController setTimelineObject:deepLinkNotification.timeline withLocation:nil orEvent:nil];
            deepLinkNotification = nil;
        }
        else
        {
            // pass the active user to profile page
            [timelineController setTimelineObject:selectedTimeline withLocation:nil orEvent:nil];
            selectedTimeline = nil;
        }
    }
    // user profile
    else if ([[segue identifier] isEqualToString:@"homeProfileSegue"]){
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        //show user profile after taping on push notification that's says someone follow you
        if([sender isKindOfClass:[AppNotification class]])
        {
            [profileController setProfileWithUser:deepLinkNotification.actor];
            deepLinkNotification = nil;
        }
        else
        {
            if(selectedTimelineToViewProfile == nil)
                [profileController setProfileWithUser:[ConnectionManager sharedManager].userObject];
            else{
                [profileController setProfileWithTimeline:selectedTimelineToViewProfile];
                selectedTimelineToViewProfile = nil;
            }
        }
    }
    // add group
    else if ([[segue identifier] isEqualToString:@"homeAddGroupSegue"]){
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        GroupDetailsController *groupDetailsController = (GroupDetailsController*)[navController viewControllers][0];
        [groupDetailsController setGroup:nil];
    }
    // go to chat from home page
    else if ([[segue identifier] isEqualToString:@"homeChatSegue"]){
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        //handle tapping on push notification that's says someone send you a message
        if([sender isKindOfClass:[AppNotification class]])
        {
            if(deepLinkNotification.type == kAppNotificationTypeNewMessageInChat){
                [chatController setTimeline:deepLinkNotification.timeline];
            }else{
                [chatController setGroup:deepLinkNotification.group withParent:nil];
            }
            deepLinkNotification = nil;
        }
        else
        {
            [chatController setTimeline:selectedTimeline];
            selectedTimeline = nil;
        }
    }else if([segue.identifier isEqualToString:@"homeUserRelatedLocationsSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        UserRelatedLocationsController *locationsController = (UserRelatedLocationsController*)[navController viewControllers][0];
        [locationsController setUserId:selectedTimelineToViewProfile.userId];
        selectedTimelineToViewProfile = nil;
    }else if ([[segue identifier] isEqualToString:@"homeTimelinesCollectionSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        TimelinesCollectionController *timelinesController = (TimelinesCollectionController*)[navController viewControllers][0];
        [timelinesController setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:deepLinkNotification.event];
        deepLinkNotification = nil;
    }
}


#pragma mark -
#pragma mark Push Notificatoins Deep linking
- (void)setRecievedDeepLinkingNotification:(AppNotification*)data
{
    deepLinkNotification = data;
}

- (void) handlePushNotificationTapEvent
{
    
    [self hideAllViews];
    switch (deepLinkNotification.type) {
        case kAppNotificationTypeSomeoneStartedFollowingYou:
        case kAppNotificationTypeSomeoneWantToFollowYou:
        case kAppNotificationTypeSomeoneAcceptYourFollowRequest:
            [self performSegueWithIdentifier:@"homeProfileSegue" sender:deepLinkNotification];
            break;
        case kAppNotificationTypeNewMessageInGroup:
        case kAppNotificationTypeSomeoneAddedYouToGroup:
        case kAppNotificationTypeNewMessageInChat:
            //[self performSegueWithIdentifier:@"notificationsListChatSegue" sender:self];
            [self performSegueWithIdentifier:@"homeChatSegue" sender:deepLinkNotification];
            break;
        case kAppNotificationTypeSomeoneMentionedYou:
            //[self performSegueWithIdentifier:@"notificationsListTimelineSegue" sender:self];
            [self performSegueWithIdentifier:@"homeTimelineSegue" sender:deepLinkNotification];
            break;
        case kAppNotificationTypeSomeoneMentionedYouInEvent:
            //[self performSegueWithIdentifier:@"notificationsListTimelinesCollectionSegue" sender:self];
            [self performSegueWithIdentifier:@"homeTimelinesCollectionSegue" sender:deepLinkNotification];
            break;
    }
    [self showAllViews];
}

-(void) hideAllViews
{
    //hide home view and disable animation to prevent transition animation
    [UIView setAnimationsEnabled:NO];
    self.view.hidden = YES;
    [self.navigationController.navigationBar setHidden:YES];
}

-(void) showAllViews
{
    //show home view and enable animation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView setAnimationsEnabled:YES];
        self.view.hidden = NO;
        [self.navigationController.navigationBar setHidden:NO];
    });
}


@end
