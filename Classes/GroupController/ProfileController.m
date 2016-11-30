//
//  ProfileController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "ProfileController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"
#import "Media.h"
#import "MediaCollectionViewCell.h"
#import "TimelineController.h"
#import "FollowingListController.h"
#import "ChatController.h"
#import "LocationCollectionViewCell.h"
#import "TimelinesCollectionController.h"
#import "WeezCollectionController.h"

@implementation ProfileController

@synthesize scrollView;
@synthesize userNameLabel;
@synthesize bioLabel;
@synthesize bioTitleLabel;
@synthesize timelineTitleLabel;
@synthesize boostsTitleLabel;
@synthesize boostsCountLabel;
@synthesize favLocationsTitleLabel;
@synthesize favLocationsCountLabel;
@synthesize mediaTitleLabel;
@synthesize mediaCountLabel;
@synthesize mediaEmptyLabel;
@synthesize duraionTitleLabel;
@synthesize viewedTitleLabel;
@synthesize duraionLabel;
@synthesize viewedLabel;
@synthesize userImage;
@synthesize timelineCoverImage;
@synthesize boostsCollectionView;
@synthesize favLocationsCollectionView;
@synthesize mediaCollectionView;
@synthesize followBtn;
@synthesize settingsBtn;
@synthesize editBtn;
@synthesize chatBtn;
@synthesize timelineContainer;
@synthesize bioContainer;
@synthesize bioContainerHeight;
@synthesize mediaContainerHeight;
@synthesize activeUser;
@synthesize boostsContainer;
@synthesize favlocationsContainer;
@synthesize mediaContainer;
@synthesize lastViewdMedia;
@synthesize lastViewesMediaIndex;
@synthesize loaderView;
@synthesize progressBgImageView;
@synthesize progressImageView;
@synthesize headerContainer;
@synthesize noBoostsLabel;
@synthesize noFavLocationsLabel;
@synthesize locationsLabel;
@synthesize locationsTitleLabel;
@synthesize followingTitleLabel;
@synthesize followingLabel;
@synthesize followersTitleLabel;
@synthesize followersLabel;
@synthesize noMediaLabel;
@synthesize privateLabel;
@synthesize privateContainer;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure controls
    [self configureViewControls];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshView:activeUser media:lastViewdMedia mediaIndex:0];
    [self loadProfile:activeUser.userId];
    // load media
    if ([listOfMedia count] == 0){
        [self loadMediaList];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resetNavBar];
}

// Configure view controls
- (void)configureViewControls{
    
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButtonBack = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButtonBack;
    
    //Done button
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endDeletionMode:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    //hide the button
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    loaderView.hidden = NO;
    //set up long press gesture recognizer for media deletion
    isDeletionMode = NO;
    if([[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId])
    {
    // attach long press gesture to collectionView
    longPressRecognzer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognzer.delegate = self;
        longPressRecognzer.delaysTouchesBegan = YES;
    }
}

- (void) refreshView:(UserProfile*)userProfile media:(Media *)media mediaIndex:(int) index {
    
    self.activeUser = userProfile;
    self.lastViewdMedia = media;
    self.lastViewesMediaIndex = index;
    BOOL isMyProfile = [[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId];
    
    combinedArrayOfFavEventAndLocations = [[NSMutableArray alloc] initWithArray:activeUser.checkedInLocationsList];
    [combinedArrayOfFavEventAndLocations addObjectsFromArray:activeUser.checkedInEventsList];
    
    //update views
    // username, duration and last updated date
    userNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    bioLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    bioTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    viewedTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    duraionTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    locationsTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    followersTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    followingTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    viewedLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    duraionLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    locationsLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    followersLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    followingLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    boostsCountLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    mediaCountLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    favLocationsCountLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    timelineTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitleBold];
    boostsTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitleBold];
    mediaTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitleBold];
    noBoostsLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    favLocationsTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitleBold];
    noFavLocationsLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    noMediaLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    mediaEmptyLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    privateLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    
    // set title
    self.navigationItem.title = activeUser.username;
    // set profile
    userImage.layer.cornerRadius = 40;
    userImage.clipsToBounds = YES;
    [userImage sd_setImageWithURL:[NSURL URLWithString:activeUser.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         UINavigationBar *navBar = self.navigationController.navigationBar;
         [[AppManager sharedManager] blurredImageWithImage:image onDone:^(UIImage *blurredImage) {
             [[AppManager sharedManager] customizeImageForNavBarBackground:blurredImage completionHandler:^(UIImage *croppedImage){
                 navBarBackGroundImage = croppedImage;
             //check if the profile controller still visible
             if(self.navigationController.topViewController == self){
                 [navBar setBackgroundImage:croppedImage forBarMetrics:UIBarMetricsDefault];
             }
             }];
         }];
     }];
    
    
    // labels
    if(activeUser.bio != nil && ![activeUser.bio isEqualToString:@""])
    {
        bioLabel.text = activeUser.bio;
        [bioLabel sizeToFit];
        CGRect labelFrame = bioLabel.frame;
        CGFloat labelHeight = labelFrame.size.height;
        bioContainerHeight.constant = labelHeight + 70;
    }
    else
    {
        bioContainerHeight.constant = 0;
    }
    userNameLabel.text = activeUser.displayName;
    viewedLabel.text = [[AppManager sharedManager] getViewedDuration:activeUser.totalViewed];
    duraionLabel.text = [[AppManager sharedManager] getMediaDuration: activeUser.mediaDuration];
    locationsLabel.text = [NSString stringWithFormat:@"%d", activeUser.locationNo];
    followingLabel.text = [NSString stringWithFormat:@"%d",(int)[activeUser.followingsList count]];
    followersLabel.text = [NSString stringWithFormat:@"%d",(int)[activeUser.followersList count]];
    bioTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_BIO_FIELD"];
    viewedTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_WATCHED_TITLE"];
    duraionTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DURATION_TITLE"];
    locationsTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_LOCATION_TITLE"];
    followersTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_FOLLOWERS_TITLE"];
    followingTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_FOLLOWING_TITLE"];
    boostsTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_BOOSTING_TIMELINES"];
    noBoostsLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_BOOSTS_EMPTY"];
    favLocationsTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_FAV_LOCATIONS"];
    noFavLocationsLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_FAV_LOCATIONS_EMPTY"];
    noMediaLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_TIMELINE_EMPTY"];
    mediaEmptyLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_TIMELINE_EMPTY"];
    privateLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_PRIVATE_CONTENT"];
    
    NSString *timeLineTitle = @"";
    if(isMyProfile){
        timeLineTitle = [[AppManager sharedManager] getLocalizedString:@"PROFILE_YOUR_TIMELINE"];
    }else{
        timeLineTitle = [[AppManager sharedManager] getLocalizedString:@"PROFILE_USER_TIMELINE"];
    }
    timelineTitleLabel.text = timeLineTitle;
    mediaTitleLabel.text = timeLineTitle;
    mediaCountLabel.text = [NSString stringWithFormat:@"%i",(int)[listOfMedia count]];
    
    // btns
    if(isMyProfile){
        settingsBtn.hidden = NO;
        editBtn.hidden = NO;
        followBtn.hidden = YES;
        chatBtn.hidden = YES;
        
        //edit photo
        editBtn.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
        
        //set underline to edit button title string
        NSString *edit = [[AppManager sharedManager] getLocalizedString:@"PREF_EDIT_PHOTO"];
        NSMutableAttributedString *editUnderlined = [[NSMutableAttributedString alloc] initWithString:edit];
        NSRange range = NSMakeRange(0, [editUnderlined length]);
        [editUnderlined addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
        [editUnderlined addAttribute: NSForegroundColorAttributeName value:[[AppManager sharedManager] getColorType:kAppColorDarkBlue] range: range];
        [editBtn setAttributedTitle:editUnderlined forState:UIControlStateNormal];
    }else{
        settingsBtn.hidden = YES;
        editBtn.hidden = YES;
        followBtn.hidden = NO;
        chatBtn.hidden = NO;
        [self updateFollowBtn];
    }
    
    // last seen media
    [timelineCoverImage sd_setImageWithURL:[NSURL URLWithString:media.largeWideThumb] placeholderImage:nil options:SDWebImageRefreshCached
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {}];
    if(lastViewdMedia != nil && [lastViewdMedia.objectId length] > 0){
        noMediaLabel.hidden = YES;
    }else{
        noMediaLabel.hidden = NO;
    }
    
    // remove previous progress bar
    for (UIImageView *img in timelineContainer.subviews){
        if ([img isKindOfClass:[UIImageView class]] && img.tag == PROGRESS_BAR_IMAGE_TAG)
            [img removeFromSuperview];
    }
    
    // set viewed percentage
    int maxWidth = self.view.frame.size.width - 2 * progressBgImageView.frame.origin.x;
    float progressWidth = (float)maxWidth * (float)activeUser.viewedPercentage / 100.0;
    progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(progressBgImageView.frame.origin.x, progressBgImageView.frame.origin.y - 1, progressWidth, 3)];
    progressImageView.tag = PROGRESS_BAR_IMAGE_TAG;
    progressImageView.backgroundColor = [[AppManager sharedManager] getColorType:kAppColorRed];
    progressImageView.clipsToBounds = YES;
    progressImageView.layer.cornerRadius = 1.5;
    [timelineContainer addSubview:progressImageView];
    
    // boosts
    if([activeUser.boosts count] > 0){
        noBoostsLabel.hidden = YES;
        boostsCountLabel.text = [NSString stringWithFormat:@"%i", (int)[activeUser.boosts count]];
    }else{
        noBoostsLabel.hidden = NO;
        boostsCountLabel.text = @"";
    }
    [boostsCollectionView reloadData];
    
    // fav locations label
    if([combinedArrayOfFavEventAndLocations count] > 0){
        noFavLocationsLabel.hidden = YES;
        favLocationsCountLabel.text = [NSString stringWithFormat:@"%i", (int)[combinedArrayOfFavEventAndLocations count]];
    }else{
        noFavLocationsLabel.hidden = NO;
        favLocationsCountLabel.text = @"";
    }
    [favLocationsCollectionView reloadData];
    
    [[AppManager sharedManager] flipViewDirection:bioContainer];
    [[AppManager sharedManager] flipViewDirection:timelineContainer];
    [[AppManager sharedManager] flipViewDirection:headerContainer];
    [[AppManager sharedManager] flipViewDirection:boostsCollectionView];
    [[AppManager sharedManager] flipViewDirection:favLocationsCollectionView];
    [[AppManager sharedManager] flipViewDirection:mediaCollectionView];
    
    boostsTitleLabel.textAlignment = NSTextAlignmentLeft;
    boostsCountLabel.textAlignment = NSTextAlignmentRight;
    favLocationsTitleLabel.textAlignment = NSTextAlignmentLeft;
    favLocationsCountLabel.textAlignment = NSTextAlignmentRight;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
    {
        boostsTitleLabel.textAlignment = NSTextAlignmentRight;
        boostsCountLabel.textAlignment = NSTextAlignmentLeft;
        favLocationsTitleLabel.textAlignment = NSTextAlignmentRight;
        favLocationsCountLabel.textAlignment = NSTextAlignmentLeft;
        mediaTitleLabel.textAlignment = NSTextAlignmentRight;
        mediaCountLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    [self updatePrivacyView];
}

-(void) updatePrivacyView
{
    BOOL isMyProfile = [[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId];
    if(isMyProfile || [activeUser isFollowing] || ![activeUser isPrivate])
    {
        [privateContainer setHidden:YES];
        [privateLabel setHidden:YES];
    }
    else//Private profile
    {
        [privateContainer setHidden:NO];
        [privateLabel setHidden:NO];
    }
}

-(void) updateFollowBtn
{
    FOLLOWING_STATE state = [activeUser getFollowingState];
    NSString *icon = @"friendFollowIcon";
    switch (state) {
//            case REQUESTED:
//                icon = @"friendFollowIconPending";
//            break;
            case FOLLOWING:
                icon = @"friendFollowIconActive";
            break;
            case NOT_FOLLOWING:
                icon = @"friendFollowIcon";
            break;
            
        default:
            break;
    }
    [followBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [followBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateDisabled];
    [followBtn setTitle:@"" forState:UIControlStateNormal];
    
}
// Follow user
-(IBAction)followAction:(id)sender{
    UIButton *senderBtn = (UIButton*) sender;
    [senderBtn setEnabled:NO];
    [[ConnectionManager sharedManager].userObject followFriend:activeUser.userId];
    // animate the pressed voted image
    senderBtn.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         senderBtn.alpha = 0.0;
         senderBtn.transform = CGAffineTransformScale(senderBtn.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         [self updateFollowBtn];
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              senderBtn.alpha = 1.0;
              senderBtn.transform = CGAffineTransformScale(senderBtn.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {
              [sender setEnabled:YES];
          }];
     }];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:activeUser.userId success:^(void)
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
         [self loadProfile:activeUser.userId];
     }
                                          failure:^(NSError * error)
     {
     }];
}

- (IBAction)showFollowers:(id)sender{
    if([activeUser.followersList count] > 0 &&
       [[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId]){
        followType = kFollowTypeFollowers;
        [self performSegueWithIdentifier:@"profileFollowingListSegue" sender:self];
    }
}

- (IBAction)showFollowing:(id)sender{
    if([activeUser.followingsList count] > 0 &&
       [[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId]){
        followType = kFollowTypeFollowing;
        [self performSegueWithIdentifier:@"profileFollowingListSegue" sender:self];
    }
}

- (IBAction)chatAction:(id)sender{
    [self performSegueWithIdentifier:@"profileChatSegue" sender:self];
}

- (IBAction)playTimelineAction:(id)sender{
    if(lastViewdMedia != nil && lastViewdMedia.objectId){
        selectedMedia = activeUser;
        playTimeLineWithSpecificMedia = NO;
        [self performSegueWithIdentifier:@"profileTimelineSegue" sender:self];
    }
}

#pragma mark -
#pragma mark delete media process

// Follow user
- (void)showDeleteMediaAlert :(UIButton*)sender
{
    int row = (int)sender.tag;
    mediaToDelete = listOfMedia[row];
    // alert messages
    NSString *titleStr = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DELETE_MEDIA_TITLE"];
    NSString *msgStr = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DELETE_MEDIA_MSG"];
    NSString *actionStr = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DELETE_MEDIA_ACTION"];
    NSString *cancelStr = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    // delete media alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                    message:msgStr
                                                   delegate:self
                                          cancelButtonTitle:cancelStr
                                          otherButtonTitles:actionStr, nil];
    [alert show];
}

// Alert view action clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){ // leave group alert
        // leave/delete group
        if (buttonIndex == 1){
            [self removeMediaProcess];
        }
    }else if(alertView.tag == 2){
        if (buttonIndex == 0)
            [self cancelAction];
    }
}


// remove media
- (void)removeMediaProcess
{
    // start loader
    [loaderView setHidden:NO];
    [self.view setUserInteractionEnabled:NO];
    [[ConnectionManager sharedManager] deleteMedia:mediaToDelete.objectId success:^
     {
         // stop loader
         [loaderView setHidden:YES];
         [self.view setUserInteractionEnabled:YES];
         //show notification
         NSString *message = @"TIMELINE_DELETE_MEDIA_SUCCESS";
         [[AppManager sharedManager] showNotification:message  withType:kNotificationTypeSuccess];
         //index of deleted media
         int mediaRow = (int)[listOfMedia indexOfObject:mediaToDelete];
         //remove media from data
         [listOfMedia removeObject:mediaToDelete];
         //remove cell
         [self removeMediaCell:mediaRow];
         //update media count label
         mediaCountLabel.text = [NSString stringWithFormat:@"%i",(int)[listOfMedia count]];
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
     }
                                          failure:^(NSError *error)
     {
         // stop loader
         [loaderView setHidden:YES];
         [self.view setUserInteractionEnabled:YES];
         // connection
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
     }];
}

-(void)removeMediaCell:(int)row {
    [self.mediaCollectionView performBatchUpdates:^{
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:row inSection:0];
        [self.mediaCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.mediaCollectionView];
    
    NSIndexPath *indexPath = [self.mediaCollectionView indexPathForItemAtPoint:p];
    
    if (indexPath == nil){//stop deletion mode after tapping out of the collection cells
        NSLog(@"couldn't find index path");
        isDeletionMode = NO;
        [mediaCollectionView reloadData];
    } else {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        isDeletionMode = YES;
        [mediaCollectionView reloadData];
    }
}

-(void)endDeletionMode :(UIBarButtonItem *)sender
{
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    isDeletionMode = NO;
    [mediaCollectionView reloadData];
}

#pragma mark -
#pragma mark - Data
- (void)loadProfile:(NSString*)userId{
    //My profile
    if([[ConnectionManager sharedManager].userObject.objectId isEqualToString:userId]){
        [[ConnectionManager sharedManager] getCurrentUserProfile:^(UserProfile* profile, Media * media, int index) {
            loaderView.hidden = YES;
            [self refreshView:profile media:media mediaIndex:index];
            
        } failure:^(NSError *error) {
            loaderView.hidden = YES;
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
        }];
    }else{
        [[ConnectionManager sharedManager] getUserProfile:activeUser.userId onSucces:^(UserProfile* profile, Media * media, int index) {
            loaderView.hidden = YES;
            [self refreshView:profile media:media mediaIndex:index];
            
        } failure:^(NSError *error) {
            loaderView.hidden = YES;
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
        }];
    }
}

// creates a profile object from User Object to fil initial data in views till we get the full profile
-(void) setProfileWithUser:(User*)user{
    UserProfile * profile = [[UserProfile alloc] init];
    profile.userId = user.objectId;
    profile.username = user.username;
    profile.profilePic = user.profilePic;
    
    self.activeUser = profile;
    combinedArrayOfFavEventAndLocations = [[NSMutableArray alloc] init];
    listOfMedia = [[NSMutableArray alloc] init];
}

// creates a profile object from Timeline Object to fil initial data in views till we get the full profile
-(void) setProfileWithTimeline:(Timeline*)Timeline{
    UserProfile * profile = [[UserProfile alloc] init];
    profile.userId = Timeline.userId;
    profile.username = Timeline.username;
    profile.profilePic = Timeline.profilePic;
    
    self.activeUser = profile;
    combinedArrayOfFavEventAndLocations = [[NSMutableArray alloc] init];
    listOfMedia = [[NSMutableArray alloc] init];
}

// creates a profile object from Timeline Object to fil initial data in views till we get the full profile
-(void) setProfileWithFriend:(Friend*)friendObj{
    UserProfile * profile = [[UserProfile alloc] init];
    profile.userId = friendObj.objectId;
    profile.username = friendObj.username;
    profile.profilePic = friendObj.profilePic;
    
    self.activeUser = profile;
    combinedArrayOfFavEventAndLocations = [[NSMutableArray alloc] init];
    listOfMedia = [[NSMutableArray alloc] init];
}

-(void) loadMediaList
{
    [[ConnectionManager sharedManager] getTimelineMedia:activeUser success:^(NSMutableArray *mediaList, int startIndex)
     {
         // set media list
         listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
         // timeline media grid
         [self.mediaCollectionView reloadData];
         mediaCountLabel.text = [NSString stringWithFormat:@"%i",(int)[listOfMedia count]];
         int mediaContentHeight = [self.mediaCollectionView.collectionViewLayout collectionViewContentSize].height;
         if([listOfMedia count] == 0)
         {
             mediaEmptyLabel.hidden = NO;
             self.mediaContainerHeight.constant = 135;
         }
         else
         {
             mediaEmptyLabel.hidden = YES;
             self.mediaContainerHeight.constant = mediaContentHeight + 50;
             //attach longpress guesture recognizer to media collectionView
             if([[ConnectionManager sharedManager].userObject.objectId isEqualToString:activeUser.userId])
             {[self.mediaCollectionView addGestureRecognizer:longPressRecognzer];}
         }
     }
                                                failure:^(NSError *error)
     {
         // show notification error
     }];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// Number of items
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(activeUser != nil){
        int boostCount = (int)[activeUser.boosts count];
        int locationsCount = (int)[combinedArrayOfFavEventAndLocations count];
        
        boostCount = boostCount > 0 ? MIN(boostCount , MAX_PROFILE_CELLS_COUNT) +1 : boostCount;
        locationsCount = locationsCount > 0 ? MIN(locationsCount , MAX_PROFILE_CELLS_COUNT) +1 : locationsCount;
        
        
        if(collectionView.tag == kBoostsCollectionTag)
            return boostCount;
        else if(collectionView.tag == kLocationsCollectionTag)
            return locationsCount;
        else
            return [listOfMedia count];
    }
    return  0;
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"profileMediaCollectionCell";
    static NSString *CellIdentifier2 = @"profileLocationCollectionCell";
    static NSString *CellIdentifier3 = @"showMoreCollectionCell";
    
    if(collectionView.tag != kMediaCollectionTag)
    {
        //check if this cell is the last one
        NSInteger itemsCount = [collectionView numberOfItemsInSection:[indexPath section]];
        if(itemsCount>0 && [indexPath row] == itemsCount - 1)
        {
            //show more cell
            UICollectionViewCell * showMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier3 forIndexPath:indexPath];
            return showMoreCell;
        }
    }
    
    if(collectionView.tag == kBoostsCollectionTag){
        MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Timeline *media = [activeUser.boosts objectAtIndex:indexPath.row];
        // populate cell
        [cell populateCellWithTimeline:media];//show cell image as circle
        return cell;
    }else if(collectionView.tag == kLocationsCollectionTag){
        LocationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier2 forIndexPath:indexPath];
        //locations
        if([[combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row] isMemberOfClass:[Location class]]){
            Location *media = [combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row];
            [cell populateCellWithLocationContent:media];
        }else{//events
            Event *media = [combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row];
            [cell populateCellWithEventContent:media];
        }
        return cell;
    }else //media collectionView
    {
        MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Media *media = listOfMedia[indexPath.row];
        [cell populateCellWithMedia:media];
        
        //chek if deletion mode on then add delete button to all cells and apply shake animation
        if(isDeletionMode)
        {
            //apply shake animation
            CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            [anim setToValue:[NSNumber numberWithFloat:0.0f]];
            [anim setFromValue:[NSNumber numberWithDouble:M_PI/64]];
            [anim setDuration:0.1];
            [anim setRepeatCount:NSUIntegerMax];
            [anim setAutoreverses:YES];
            cell.layer.shouldRasterize = YES;
            [cell.layer addAnimation:anim forKey:@"SpringboardShake"];
            //show delete button
            [cell showDeleteMode:YES];
            cell.deleteButton.tag = indexPath.row;
            [cell.deleteButton addTarget:self action:@selector(showDeleteMediaAlert:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {   
            [cell showDeleteMode:NO];
            [cell.layer removeAllAnimations];
        }
        
        return cell;
    }
}

#pragma mark -
#pragma mark - UICollectionViewDelegate
// Select item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //check if tapping on showmore cell
    if(collectionView.tag != kMediaCollectionTag)
    {
        //check if this cell is the last one
        NSInteger itemsCount = [collectionView numberOfItemsInSection:[indexPath section]];
        if(itemsCount>0 && [indexPath row] == itemsCount - 1)
        {
            [self performSegueWithIdentifier:@"profileWeezCollectionSegue" sender: collectionView];
            return;
        }
    }
    
    if(collectionView.tag == kBoostsCollectionTag){
        selectedMedia = [activeUser.boosts objectAtIndex:indexPath.row];
        playTimeLineWithSpecificMedia = NO;
        [self performSegueWithIdentifier:@"profileTimelineSegue" sender:self];
    }else if(collectionView.tag == kLocationsCollectionTag){
        if([[combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row] isMemberOfClass:[Location class]]){
            selectedLocation = [combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row];
        }else{
            selectedEvent = [combinedArrayOfFavEventAndLocations objectAtIndex:indexPath.row];
        }
        [self performSegueWithIdentifier:@"profileTimelinesCollectionSegue" sender:self];
    }else{
        selectedMedia = activeUser;
        if(isDeletionMode){
            MediaCollectionViewCell *cell = (MediaCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            cell.deleteButton.tag = indexPath.row;
            [self showDeleteMediaAlert:cell.deleteButton];
        }
        else{
            playTimeLineWithSpecificMedia = YES;
        selectedMediaIndex = (int)indexPath.row;
            [self performSegueWithIdentifier:@"profileTimelineSegue" sender:self];
        }
    }
}

#pragma mark –
#pragma mark – UICollectionViewDelegateFlowLayout
// Item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag == kMediaCollectionTag)
    {
        float screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
        return CGSizeMake(screenWidth/3,screenWidth/3);
    }
    else
    {
        return CGSizeMake(93, 85);
    }
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"profileTimelineSegue"]){
        TimelineController *controler = (TimelineController*) segue.destinationViewController;
        [controler setTimelineObject:selectedMedia withLocation:nil orEvent:nil];
        if(playTimeLineWithSpecificMedia){
            [controler setMediaList:listOfMedia withSelectedIndex:selectedMediaIndex];
        }
    }else if ([[segue identifier] isEqualToString:@"profileFollowingListSegue"]){
        // pass the active user
        FollowingListController *profileController = (FollowingListController*)[segue destinationViewController];
        [profileController setFollowType:followType];
    }else if([segue.identifier isEqualToString:@"profileChatSegue"]){
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        [chatController setTimeline:activeUser];
    }else if ([[segue identifier] isEqualToString:@"profileTimelinesCollectionSegue"]){
        if(selectedLocation != nil){
            // pass the selected Location
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
        }else{
            // pass the selected event
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:selectedEvent];
        }
        selectedLocation = nil;
        selectedEvent = nil;
    }else if([[segue identifier] isEqualToString:@"profileWeezCollectionSegue"])
    {
    UINavigationController *navController = [segue destinationViewController];
        WeezCollectionController *controller = (WeezCollectionController*)[navController viewControllers][0];
        UICollectionView * senderCollectionView = sender;
        if(senderCollectionView.tag == kBoostsCollectionTag)
            [controller loadViewWithData:activeUser.boosts type:COLLECTION_TYPE_TIMELINES];
        else
            [controller loadViewWithData:combinedArrayOfFavEventAndLocations type:COLLECTION_TYPE_LOACTIONS];
    }
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - navbar style
-(void)setNavBarColor: (UIColor*) color
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    // set status bar to white
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setBarTintColor:color];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void) resetNavBar
{
    //remove background image
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    // set the navbar color to its original status
    [self setNavBarColor:[[AppManager sharedManager] getColorType:kAppColorBlue]];
}

@end
