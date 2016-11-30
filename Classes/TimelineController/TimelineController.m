//
//  TimelineController.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineController.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"
#import "Media.h"
#import "AppManager.h"
#import "ProfileController.h"
#import "StreamCollectionCell.h"
#import "TimelinesCollectionController.h"
#import "AddMentionController.h"
#import "SocialManager.h"

@implementation TimelineController

@synthesize bgImageView;
@synthesize detailsView;
@synthesize profileImageView;
@synthesize progressBgImageView;
@synthesize usernameLabel;
@synthesize lastDateLabel;
@synthesize startButton;
@synthesize followButton;
@synthesize shareButton;
@synthesize boostButton;
@synthesize mentionButton;
@synthesize durationTitleLabel;
@synthesize durationLabel;
@synthesize watchedView;
@synthesize watchedTitleLabel;
@synthesize watchedLabel;
@synthesize locationTitleLabel;
@synthesize locationLabel;
@synthesize swipeabaleLayout;
@synthesize pauseButton;
@synthesize boostsCountIcon;
@synthesize boostsCountLabel;
@synthesize privateLabel;
@synthesize privateContainer;
// mention & boost
@synthesize actorView;
@synthesize actorImageView;
@synthesize actorTitleLabel;
@synthesize actorLabel;
// player
@synthesize player;
@synthesize isPaused;
@synthesize playContainerView;
@synthesize footerContainerView;
@synthesize timelineCollectionView;
@synthesize closeButton;
@synthesize overlayButton;
@synthesize mediaLocView;
@synthesize mediaLocImageView;
@synthesize mediaLocLabel;
@synthesize loaderView;
@synthesize timelineLocation;
@synthesize timelineEvent;
@synthesize hasNextTimeline;
@synthesize hasPrevTimeline;
@synthesize infoButton;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure view
    [self configureView];
    // configure player view
    [self configurePlayerView];
    // hide player
    //[playContainerView setHidden:YES];
    [self showDetailsView:NO];
    [self showActionsButtons:NO];
    [self showMediaSellectionFooter:NO fullHide:NO];
    
    isFirstTime = YES;
    isFullScreen = NO;
    
    if(playSpecificMedia)
    {
        playIndex = initialMediaIndex;
        playSpecificMedia = NO;
        [self playSelectedMedia];
    }
}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // load media
    if ([listOfMedia count] == 0){
        [self loadMediaList];
    }
    // temp
    [self.startButton removeFromSuperview];
}

// View will disappear
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // stop player
    //[player pause];
}

// Configure view controls
- (void)configureView{
    BOOL isMyProfile = [activeTimeline.userId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId];
    detailsView.layer.cornerRadius = 2.0;
    [[AppManager sharedManager] addViewDropShadow:detailsView withOpacity:0.6];
    // set thumbnail
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.layer.masksToBounds = YES;
    [bgImageView sd_setImageWithURL:[NSURL URLWithString:activeTimeline.portraitThumb] placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
     }];
    // set profile
    TimelineController __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:activeTimeline.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    [self updateFollowBtn];
    // this is my profile
    [followButton setHidden:NO];
    [boostsCountLabel setHidden:YES];
    [boostsCountIcon setHidden:YES];
    if (isMyProfile){
        [followButton setHidden:YES];
        [boostsCountLabel setHidden:NO];
        [boostsCountIcon setHidden:NO];
    }
    // username, duration and last updated date
    usernameLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    usernameLabel.text = activeTimeline.username;
    lastDateLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    lastDateLabel.text = [activeTimeline getUpdatedDateString:YES];
    boostsCountLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    durationTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    durationTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DURATION_TITLE"];
    watchedTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    watchedTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_WATCHED_TITLE"];
    locationTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    locationTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_LOCATION_TITLE"];
    durationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:activeTimeline.mediaDuration];
    watchedLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    watchedLabel.text = [[AppManager sharedManager] getMediaDuration:activeTimeline.totalViewed];
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    locationLabel.text = [NSString stringWithFormat:@"%i", activeTimeline.locationNo];
    mediaLocLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    
    privateLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    privateLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_PRIVATE_CONTENT"];
    // mention & boost
    actorTitleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    actorLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    actorLabel.text = activeTimeline.actorUsername;
    //[actorView setHidden:YES];
    // show watched view for regular timelines only
    //[watchedView setHidden:NO];
    if (activeTimeline.timelineType == kTimelineTypeBoost)
    {
        //[watchedView setHidden:YES];
        //[actorView setHidden:NO];
        actorImageView.image = [UIImage imageNamed:@"timelineBoostGreyIcon"];
        actorTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_BOOSTED_TITLE"];
    }
    else if (activeTimeline.timelineType == kTimelineTypeMention)
    {
        //[watchedView setHidden:YES];
        //[actorView setHidden:NO];
        actorImageView.image = [UIImage imageNamed:@"timelineMentionGreyIcon"];
        actorTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_MENTION_TITLE"];
    }
    
    //    [[AppManager sharedManager] addViewDropShadow:usernameLabel];
    //    [[AppManager sharedManager] addViewDropShadow:lastDateLabel];
    //    [[AppManager sharedManager] addViewDropShadow:durationTitleLabel];
    //    [[AppManager sharedManager] addViewDropShadow:watchedTitleLabel];
    //    [[AppManager sharedManager] addViewDropShadow:locationTitleLabel];
    //    [[AppManager sharedManager] addViewDropShadow:durationLabel];
    //    [[AppManager sharedManager] addViewDropShadow:watchedLabel];
    //    [[AppManager sharedManager] addViewDropShadow:locationLabel];
    
    // set viewed percentage
    //    int maxWidth = self.view.frame.size.width - 2 * progressBgImageView.frame.origin.x - 2 * detailsView.frame.origin.x;
    //    float progressWidth = (float)maxWidth * (float)activeTimeline.viewedPercentage / 100.0;
    //    progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(progressBgImageView.frame.origin.x, progressBgImageView.frame.origin.y - 1, progressWidth, 3)];
    //    progressImageView.tag = PROGRESS_BAR_IMAGE_TAG;
    //    progressImageView.backgroundColor = [[AppManager sharedManager] getColorType:kAppColorRed];
    //    progressImageView.clipsToBounds = YES;
    //    progressImageView.layer.cornerRadius = 1.5;
    //    [detailsView addSubview:progressImageView];
    
    // blur view
    //    self.view.backgroundColor = [UIColor clearColor];
    //    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //    blurEffectView.frame = self.view.bounds;
    //    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //    [self.view insertSubview:blurEffectView aboveSubview:overlayButton];
    // flip search bar
    [[AppManager sharedManager] flipViewDirection:detailsView];
    
    if(timelineLocation || timelineEvent){
        swipeabaleLayout.hidden = NO;
        UIPanGestureRecognizer *gestRecRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiepeOnScreen:)];
        [overlayButton addGestureRecognizer:gestRecRight];
        self.enableSwipeToBack = NO;
    }else{
        swipeabaleLayout.hidden = YES;
    }
    
    self.swipeabaleLayoutXCenterConstraint.constant = (self.view.frame.size.width);
    hasNextTimeline = NO;
    hasPrevTimeline = NO;
    
    // init boost button
    if ([listOfMedia count] != 0){
        Media * media = [listOfMedia objectAtIndex:playIndex];
        if([media isMediaBoosted])
            [boostButton setImage:[UIImage imageNamed:@"timelineBoostActive"] forState:UIControlStateNormal];
        else
            [boostButton setImage:[UIImage imageNamed:@"timelineBoostWhiteIcon"] forState:UIControlStateNormal];
    }
    
    [self updatePrivacyView];
}

- (void) refreshView{
    [bgImageView sd_setImageWithURL:[NSURL URLWithString:activeTimeline.portraitThumb] placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
     }];
    // set profile
    TimelineController __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:activeTimeline.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    [self updateFollowBtn];
    // this is my profile
    [followButton setHidden:NO];
    if ([activeTimeline.userId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId])
        [followButton setHidden:YES];
    // username, duration and last updated date
    usernameLabel.text = activeTimeline.username;
    lastDateLabel.text = [activeTimeline getUpdatedDateString:YES];
    durationTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_DURATION_TITLE"];
    watchedTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_WATCHED_TITLE"];
    locationTitleLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_LOCATION_TITLE"];
    durationLabel.text = [[AppManager sharedManager] getMediaDuration:activeTimeline.mediaDuration];
    watchedLabel.text = [[AppManager sharedManager] getMediaDuration:activeTimeline.totalViewed];
    locationLabel.text = [NSString stringWithFormat:@"%i", activeTimeline.locationNo];
    
    // set viewed percentage
    int maxWidth = self.view.frame.size.width - (2*progressBgImageView.frame.origin.x) - (2*detailsView.frame.origin.x);
    float progressWidth = (float)maxWidth * (float)activeTimeline.viewedPercentage / 100.0;
    [progressImageView removeFromSuperview];
    progressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(progressBgImageView.frame.origin.x, progressBgImageView.frame.origin.y - 1, progressWidth, 3)];
    progressImageView.backgroundColor = [[AppManager sharedManager] getColorType:kAppColorBlue];
    progressImageView.clipsToBounds = YES;
    progressImageView.layer.cornerRadius = 1.5;
    [detailsView addSubview:progressImageView];
}

-(void) updatePrivacyView
{
    BOOL isMyProfile = [activeTimeline.userId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId];
    BOOL isUserRelatedTimeline = (activeTimeline.timelineType == kTimelineTypeBoost) || (activeTimeline.timelineType == kTimelineTypeMention) || (activeTimeline.timelineType == kTimelineTypeUser);
    
    if(activeTimeline.isPrivate && isUserRelatedTimeline)
    {
        [shareButton setHidden:YES];//prevent social share for private media
        if(!isMyProfile)
        {
            [mentionButton setHidden:YES];
            [boostButton setHidden:YES];
            if (![activeTimeline isFollowing])
            {
                [privateContainer setHidden:NO];
            }
            else
            {
                [privateContainer setHidden:YES];
            }
        }
        else
        {
            [privateContainer setHidden:YES];
        }
    }
    else
    {
        [shareButton setHidden:NO];
        [mentionButton setHidden:NO];
        [boostButton setHidden:NO];
        [privateContainer setHidden:YES];
    }
}

-(void) updateFollowBtn
{
    FOLLOWING_STATE state = [activeTimeline getFollowingState];
    NSString *icon = @"friendFollowIcon";
    switch (state) {
        case REQUESTED:
            icon = @"friendFollowIconPending";
            break;
        case FOLLOWING:
            icon = @"friendFollowIconActive";
            break;
        case NOT_FOLLOWING:
            icon = @"friendFollowIcon";
            break;
            
        default:
            break;
    }
    [followButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [followButton setImage:[UIImage imageNamed:icon] forState:UIControlStateDisabled];
    [followButton setTitle:@"" forState:UIControlStateNormal];
}

-(void) refreshLocationInfoViewsWithMedia:(Media*)media{
    TimelineController __weak *weakSelf = self;
    // set location if exist
    if ([media.location.objectId length] > 0 || [media.event.objectId length] > 0 )
    {
        BOOL hasEvent = [media.event.objectId length] > 0;
        NSString *locationImagePath = hasEvent?media.event.image:media.location.image;
        NSString *locationName = hasEvent?media.event.name:media.location.name;
        [mediaLocView setHidden:NO];
        mediaLocLabel.text = locationName;
        // load location image
        [mediaLocImageView sd_setImageWithURL:[NSURL URLWithString:locationImagePath] placeholderImage:nil options:SDWebImageRefreshCached
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             weakSelf.mediaLocImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.mediaLocImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
         }];
    }else{
        [mediaLocView setHidden:YES];
    }
    
    // boosts count "for media owner only"
    if([activeTimeline.userId isEqualToString:[ConnectionManager sharedManager].userObject.objectId]){
        boostsCountLabel.text = [NSString stringWithFormat:@"%d", media.boostCount];
        [boostsCountLabel setHidden:NO];
        [boostsCountIcon setHidden:NO];
    }else{
        [boostsCountLabel setHidden:YES];
        [boostsCountIcon setHidden:YES];
    }
    
    // boost button
    if([media isMediaBoosted])
        [boostButton setImage:[UIImage imageNamed:@"timelineBoostActive"] forState:UIControlStateNormal];
    else
        [boostButton setImage:[UIImage imageNamed:@"timelineBoostWhiteIcon"] forState:UIControlStateNormal];
}

// Configure player controls
- (void)configurePlayerView
{
    player = [[SSVideoPlayer alloc]init];
    player.delegate = self;
    player.displayMode = SSVideoPlayerDisplayModeAspectFill;
    __weak TimelineController *weakSelf = self;
    player.bufferProgressBlock = ^(float f) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // not paused
            if (! weakSelf.isPaused)
                [weakSelf.player play];
        });
    };
    player.progressBlock = ^(float f) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    };
    isPaused = NO;
    // init player
    playContainerView.frame = self.view.frame;
    [player playInContainer:playContainerView];
    playIndex = 0;
    // flip thumbnail bar
    [[AppManager sharedManager] flipViewDirection:timelineCollectionView];
}

- (void)setTimelineObject:(Timeline*)timelineObj withLocation:(Location*)location orEvent:(Event*)event
{
    activeTimeline = timelineObj;
    timelineLocation = location;
    timelineEvent = event;
}
//play media when it is selected from profile grid
- (void)setMediaList:(NSMutableArray*)mediaList withSelectedIndex:(int)indexToPlay
{
    // stop loader
    [startButton setEnabled:YES];
    [self stopIndicator];
    // set media list
    listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
    initialMediaIndex = indexToPlay;
    [self refreshLocationInfoViewsWithMedia:listOfMedia[playIndex]];
    [self.timelineCollectionView reloadData];
    playSpecificMedia = YES;
}

-(void) playSelectedMedia
{
    Media *model = listOfMedia[playIndex];
    [self playMediaWithPath:model];
    [timelineCollectionView reloadData];
}
// Load media list
- (void)loadMediaList
{
    // hide details
    startButton.alpha = 0.0;
    blurEffectView.alpha = 0.0;
    [startButton setHidden:NO];
    [blurEffectView setHidden:NO];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         startButton.alpha = 1.0;
         blurEffectView.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
     }];
    // start loading
    [startButton setEnabled:NO];
    [self startIndicator];
    // if this is a location timeline
    if(timelineLocation != nil){
        [[ConnectionManager sharedManager] getTimelineMediaInLocation:activeTimeline.userId locationId:timelineLocation.objectId success:^(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev)
         {
             // stop loader
             [startButton setEnabled:YES];
             [self stopIndicator];
             // set media list
             listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
             playIndex = startIndex;
             
             hasPrevTimeline = hasPrev;
             hasNextTimeline = hasNext;
             
             [self refreshLocationInfoViewsWithMedia:listOfMedia[playIndex]];
             [self.timelineCollectionView reloadData];
             
             if(isFirstTime){
                 [self startAction:nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     Media *model = listOfMedia[playIndex];
                     if (model.mediaType == kMediaTypeVideo)
                         [player play];
                 });
             }
         }
                                                              failure:^(NSError *error)
         {
             [self stopIndicator];
             hasPrevTimeline = NO;
             hasNextTimeline = NO;
             // show notification error
             [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }else if(timelineEvent != nil){ //this is an event timeline
        [[ConnectionManager sharedManager] getTimelineMediaInEvent:activeTimeline.userId eventId:timelineEvent.objectId success:^(NSMutableArray *mediaList, int startIndex, BOOL hasNext, BOOL hasPrev)
         {
             // stop loader
             [startButton setEnabled:YES];
             [self stopIndicator];
             // set media list
             listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
             playIndex = startIndex;
             
             hasPrevTimeline = hasPrev;
             hasNextTimeline = hasNext;
             
             [self refreshLocationInfoViewsWithMedia:listOfMedia[playIndex]];
             [self.timelineCollectionView reloadData];
             
             if(isFirstTime){
                 [self startAction:nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     Media *model = listOfMedia[playIndex];
                     if (model.mediaType == kMediaTypeVideo)
                         [player play];
                 });
             }
         }
                                                           failure:^(NSError *error)
         {
             [self stopIndicator];
             hasPrevTimeline = NO;
             hasNextTimeline = NO;
             // show notification error
             [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }else{// if this is a user timeline
        [[ConnectionManager sharedManager] getTimelineMedia:activeTimeline success:^(NSMutableArray *mediaList, int startIndex)
         {
             // stop loader
             [startButton setEnabled:YES];
             [self stopIndicator];
             // set media list
             listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
             playIndex = startIndex;
             [self refreshLocationInfoViewsWithMedia:listOfMedia[playIndex]];
             [self.timelineCollectionView reloadData];
             
             if(isFirstTime)
                 [self startAction:nil];
         }
                                                    failure:^(NSError *error)
         {
             [self stopIndicator];
             
             if(error)
             {
                 if(ERROR_PRIVECY == error.code)
                 {
                     activeTimeline.isPrivate = YES;
                     [self updatePrivacyView];
                     return;
                 }
             }
             // show notification error
             [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }
}

- (void)loadNextTimeline:(BOOL)next{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    // Always use this locale when parsing fixed format date strings
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    NSString *date = [formatter stringFromDate:activeTimeline.lastMediaDate];
    
    isLoadingTimeline = YES;
    
    [[ConnectionManager sharedManager] getNextTimelineInLocation:timelineLocation.objectId orEvent:(NSString*)timelineEvent.objectId next:next currentlyWatchedUserId:activeTimeline.userId dateOfCurrentTimeline:date success:^(Timeline * newActiveTimeline, NSMutableArray* mediaList,int lastViewedMediaIndex, BOOL hasMore){
        // configure view
        [self.loaderView stopAnimating];
        isLoadingTimeline = NO;
        activeTimeline = newActiveTimeline;
        if(next){
            hasPrevTimeline = YES;
            hasNextTimeline = hasMore;
        }else{
            hasNextTimeline = YES;
            hasPrevTimeline = hasMore;
        }
        isFirstTime = YES;
        [self refreshView];
        // configure player view
        [self configurePlayerView];
        // hide player
        //[playContainerView setHidden:YES];
        [self showMediaSellectionFooter:NO fullHide:YES];
        
        // stop loader
        [startButton setEnabled:YES];
        [self stopIndicator];
        // set media list
        listOfMedia = [[NSMutableArray alloc] initWithArray:mediaList];
        playIndex = lastViewedMediaIndex;
        [self refreshLocationInfoViewsWithMedia:listOfMedia[playIndex]];
        [self.timelineCollectionView reloadData];
        
        // autoplay
        [self startAction:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            Media *model = listOfMedia[playIndex];
            if (model.mediaType == kMediaTypeVideo)
                [player play];
        });
        
    } failure:^(NSDictionary *error) {
        isLoadingTimeline = NO;
        [self.loaderView stopAnimating];
        //id errorObject = [responseObject objectForKey:@"error"];
        if(error != nil && [error objectForKey:@"error"] != nil){
            NSString *errorMsg = [error objectForKey:@"error"];
            if([errorMsg isEqualToString:@"no_data"]){
                if(next){
                    hasNextTimeline = NO;
                }else{
                    hasPrevTimeline = NO;
                }
            }
        }
    }
     ];
}

- (IBAction)actionNextTimeline:(id)sender{
    [self loadNextTimeline:YES];
}
- (IBAction)actionPrevTimeline:(id)sender{
    [self loadNextTimeline:NO];
}

// Cancel action
- (IBAction)cancelAction:(id)sender
{
    [playImageTimer invalidate];
    playImageTimer = nil;
    [self pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Show user profile
- (IBAction)profileAction:(id)sender
{
    [self performSegueWithIdentifier:@"timelineProfileSegue" sender:self];
}

// Play timeline
- (IBAction)startAction:(id)sender
{
    if([listOfMedia count] <= 0)
        return;
    
    if (isFirstTime)
    {
        [self startVideoMode];
        if(isDetailVisible)
            [self showDetailsView:NO];
        
        return;
    }
    // play
    if (isPaused)
    {
        [self play];
    }
    else// pause player
    {
        [self pause];
    }
    if(isDetailVisible)
        [self showDetailsView:NO];
}

// Start video mode
- (void)startVideoMode{
    
    // start indicator
    if (isFirstTime)
    {
        [self startIndicator];
        [self playCurrentMedia];
        isFirstTime = NO;
    }
}

// Start video mode
- (void)stopVideoMode
{
    // hide details
    startButton.alpha = 0.0;
    blurEffectView.alpha = 0.0;
    [startButton setHidden:NO];
    [blurEffectView setHidden:NO];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         startButton.alpha = 1.0;
         blurEffectView.alpha = 1.0;
     }
                     completion:^(BOOL finished)
     {
     }];
    [self stopIndicator];
    
}


// Follow action
- (IBAction)followAction:(id)sender
{
    [followButton setEnabled:NO];
    [[ConnectionManager sharedManager].userObject followFriend:activeTimeline.userId withPrivateProfile:activeTimeline.isPrivate];
    // animate the pressed voted image
    followButton.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         followButton.alpha = 0.0;
         followButton.transform = CGAffineTransformScale(followButton.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         [self updateFollowBtn];
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              followButton.alpha = 1.0;
              followButton.transform = CGAffineTransformScale(followButton.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {
              [followButton setEnabled:YES];
          }];
     }];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:activeTimeline.userId success:^(void)
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
     }
                                          failure:^(NSError * error)
     {
     }];
}

// Share action
- (IBAction)shareAction:(id)sender
{
    [self pause];
    // action sheet options
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList = @[[[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ALERT_TITLE"], [[AppManager sharedManager] getLocalizedString:@"TWITTER_ALERT_TITLE"],
                            [[AppManager sharedManager] getLocalizedString:@"INSTAGRAM_ALERT_TITLE"], [[AppManager sharedManager] getLocalizedString:@"COPYLINK_ALERT_TITLE"]];
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:4];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:0];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:1];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:2];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:3];
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:4];
    // add images
    NSArray *buttonsArray = [actionOptions buttons];
    UIButton *btnFacebook = [buttonsArray objectAtIndex:0];
    [btnFacebook setImage:[UIImage imageNamed:@"sharingFacebookIcon"] forState:UIControlStateNormal];
    btnFacebook.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnFacebook.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 48.0f, 0.0f, 0.0f);
    btnFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnTwitter = [buttonsArray objectAtIndex:1];
    [btnTwitter setImage:[UIImage imageNamed:@"sharingTwitterIcon"] forState:UIControlStateNormal];
    btnTwitter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTwitter.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnTwitter.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnInstagram = [buttonsArray objectAtIndex:2];
    [btnInstagram setImage:[UIImage imageNamed:@"sharingInstagramIcon"] forState:UIControlStateNormal];
    btnInstagram.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnInstagram.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnInstagram.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnCopyLink = [buttonsArray objectAtIndex:3];
    [btnCopyLink setImage:[UIImage imageNamed:@"sharingCopyLinkIcon"] forState:UIControlStateNormal];
    btnCopyLink.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnCopyLink.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnCopyLink.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    // view the action sheet
    [actionOptions showInView:self.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}

// Boost action
- (IBAction)boostAction:(id)sender
{
    // check play index
    if (playIndex < [listOfMedia count]){
        Media *media = listOfMedia[playIndex];
        
        boostButton.alpha = 1.0;
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
         {
             boostButton.alpha = 0.0;
             boostButton.transform = CGAffineTransformScale(boostButton.transform, 0.5, 0.5);
         }
                         completion:^(BOOL finished)
         {
             // toggle boost icon temporarly till we get the responce from the server
             if([media isMediaBoosted])
                 [boostButton setImage:[UIImage imageNamed:@"timelineBoostWhiteIcon"] forState:UIControlStateNormal];
             else
                 [boostButton setImage:[UIImage imageNamed:@"timelineBoostActive"] forState:UIControlStateNormal];

             [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
              {
                  boostButton.alpha = 1.0;
                  boostButton.transform = CGAffineTransformScale(boostButton.transform, 2.0, 2.0);
              }
                              completion:^(BOOL finished)
              {
                  [boostButton setEnabled:YES];
              }];
         }];
        
        // boost media
        [[ConnectionManager sharedManager] boostMedia:activeTimeline.userId withMediaId:media.objectId success:^
         {
             // notify about timeline changes
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
             // show notification success
             //[[AppManager sharedManager] showNotification:@"TIMELINE_BOOST_SUCCESS" withType:kNotificationTypeSuccess];
             [self loadMediaList];
         }
                                              failure:^(NSError *error)
         {
             // show notification error
             [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }
}

- (IBAction)infoAction:(id)sender
{
    [self pause];
    [self showDetailsView:YES];
    [self showActionsButtons:NO];
    
    [self showMediaSellectionFooter:NO fullHide:YES];
}

- (void) showDetailsView:(BOOL) show
{
    if(show){
        self.detailsViewBottomConstraint.constant = 0;
        [self.detailsView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.detailsView layoutIfNeeded];
        }
                         completion:^(BOOL finished)
         {
             isDetailVisible = YES;
             [infoButton setHidden:YES];
         }];
        
    }else{
        self.detailsViewBottomConstraint.constant = - detailsView.frame.size.height -20;
        [self.detailsView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.detailsView layoutIfNeeded];
        }
                         completion:^(BOOL finished)
         {
             isDetailVisible = NO;
         }];
    }
}

- (void) showMediaSellectionFooter:(BOOL) show fullHide:(BOOL) fullHide
{
    //    if(show == !footerContainerView.hidden)
    //        return;
    if(show){
        self.mediaSelectionBottomConstraint.constant = 0;
        [self.footerContainerView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.footerContainerView layoutIfNeeded];
        }];
    }else{
        self.mediaSelectionBottomConstraint.constant = - footerContainerView.frame.size.height;
        if(!fullHide)
            self.mediaSelectionBottomConstraint.constant = - footerContainerView.frame.size.height + 45;
        [self.footerContainerView setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.footerContainerView layoutIfNeeded];
        }];
    }
}

- (void) showActionsButtons:(BOOL) show
{
    //    BOOL actionsVisible = self.boostButtonLeadingConstraint.constant >= 0;
    //    if(show == actionsVisible)
    //        return;
    //
    isMediaControllsVisible = show;
    if(show){
        self.boostButtonLeadingConstraint.constant = 12;
        self.mentionButtonTrailingConstraint.constant = 12;
        self.shareButtonTrailingConstraint.constant = 12;
        self.infoButtonLeadingConstraint.constant = 12;
        [self.mentionButton setNeedsUpdateConstraints];
        [self.shareButton setNeedsUpdateConstraints];
        [self.boostButton setNeedsUpdateConstraints];
        [self.infoButton setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.mentionButton layoutIfNeeded];
            [self.shareButton layoutIfNeeded];
            [self.boostButton layoutIfNeeded];
            [self.infoButton layoutIfNeeded];
            pauseButton.alpha = 1.0;
        }];
        [infoButton setHidden:NO];
    }else{
        self.boostButtonLeadingConstraint.constant = -60;
        self.mentionButtonTrailingConstraint.constant = -60;
        self.shareButtonTrailingConstraint.constant = -60;
        self.infoButtonLeadingConstraint.constant = -60;
        [self.mentionButton setNeedsUpdateConstraints];
        [self.shareButton setNeedsUpdateConstraints];
        [self.boostButton setNeedsUpdateConstraints];
        [self.infoButton setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.3 animations:^{
            [self.mentionButton layoutIfNeeded];
            [self.shareButton layoutIfNeeded];
            [self.boostButton layoutIfNeeded];
            [self.infoButton layoutIfNeeded];
            pauseButton.alpha = 0.0;
        }];
    }
    
}

// Mention action
- (IBAction)mentionAction:(id)sender
{
    [self performSegueWithIdentifier:@"timelineAddMentionSegue" sender:self];
    [self performSelector:@selector(pauseBeforeSwitchingController) withObject:nil afterDelay:0.5];
}

// Mention process
- (void)mentionProcess:(NSMutableArray*)mentionList
{
    // check play index
    if (playIndex < [listOfMedia count])
    {
        Media *media = listOfMedia[playIndex];
        // boost media
        [[ConnectionManager sharedManager] mentionMedia:activeTimeline.userId withMediaId:media.objectId withMentionList:mentionList success:^
         {
             // notify about timeline changes
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
             // show notification success
             [[AppManager sharedManager] showNotification:@"TIMELINE_MENTION_SUCCESS" withType:kNotificationTypeSuccess];
         }
                                                failure:^(NSError *error)
         {
             // show notification error
             [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }
}

// Open location action
- (IBAction)openLocationAction:(id)sender
{
    [self performSegueWithIdentifier:@"TimelineTimelinesCollectionSegue" sender:self];
    [self performSelector:@selector(pauseBeforeSwitchingController) withObject:nil afterDelay:0.5];
}

// Pause before open location details
- (void)pauseBeforeSwitchingController
{
    [self pause];
    [self showMediaSellectionFooter:YES fullHide:YES];
}

-(void) pause{
    isPaused = YES;
    // resume video
    Media *model = listOfMedia[playIndex];
    if (model.mediaType == kMediaTypeVideo)
        [player pause];
    [self stopVideoMode];
    [pauseButton setImage:[UIImage imageNamed:@"videoPlayIcon"] forState:UIControlStateNormal];
    //[self showMediaSellectionFooter:YES fullHide:NO];
    if(isDetailVisible)
        [self showDetailsView:NO];
}

-(void) play{
    isPaused = NO;
    // resume video
    Media *model = listOfMedia[playIndex];
    if (model.mediaType == kMediaTypeVideo)
        [player play];
    [self startVideoMode];
    [pauseButton setImage:[UIImage imageNamed:@"videoPauseIcon"] forState:UIControlStateNormal];
    //[self showMediaSellectionFooter:NO fullHide:NO];
    if(isDetailVisible)
        [self showDetailsView:NO];
}

-(void) didFinishMedia{
    // out of range
    if (playIndex >= [listOfMedia count] - 1)
    {
        // if we are playing location or event timelines then jump to the next timeline
        if((timelineLocation || timelineEvent) && hasNextTimeline){
            [self actionNextTimeline:nil];
        }else{
            [self cancelAction:nil];
        }
        return;
    }
    // play next media
    playIndex++;
    [self playCurrentMedia];
}

- (IBAction)actionPause:(id)sender{
    // play
    if (isPaused)
    {
        [self play];
        [self showActionsButtons:NO];
    }else// pause player
    {
        [self pause];
    }
}

// action called when pressing the media overlay "touching the screen"
- (IBAction)playAction:(id)sender
{
    // hide media Controlls
    if (isMediaControllsVisible)
    {
        if(isPaused)
            [self play];
        [self showActionsButtons:NO];
        [self showMediaSellectionFooter:NO fullHide:NO];
    }
    else// show media Controlls
    {
        [self showActionsButtons:YES];
        [self showMediaSellectionFooter:YES fullHide:NO];
    }
    
    if(isDetailVisible)
        [self showDetailsView:NO];
}

// Play for certain path
- (void)playMediaWithPath:(Media*)media
{
    NSString *path = media.mediaLink;
    int duration = media.duration;
    [self refreshLocationInfoViewsWithMedia:media];
    TimelineController __weak *weakSelf = self;
    // video case
    if (media.mediaType == kMediaTypeVideo)
    {
        // stop image timer
        [playImageTimer invalidate];
        playImageTimer = nil;
        // send image to back view
        [self.view sendSubviewToBack:bgImageView];
        [self.view sendSubviewToBack:swipeabaleLayout];
        // refresh video player path
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // make sure we reset the path before changing it
            // if we didnt reset it the player will refuse to play the same video after its
            // finished till we move to a different visoe with different path
            player.path = nil;
            player.path = path;
        });
    }
    else// image case
    {
        // stop video player
        [player pause];
        // send video to back view
        [self.view sendSubviewToBack:playContainerView];
        [self.view sendSubviewToBack:swipeabaleLayout];
        // load media
        [self.loaderView startAnimating];
        [bgImageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:nil options:SDWebImageRefreshCached
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             [weakSelf.loaderView stopAnimating];
             if(!isPaused)
                 [self startPlayImage:duration];
         }];
    }
    // media watched
    [[ConnectionManager sharedManager] watchMedia:activeTimeline.userId withMediaId:media.objectId success:^
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
     }
                                          failure:^(NSError *error)
     {
     }];
}

// Start loader
- (void)startIndicator
{
    if (![loaderView isAnimating])
    {
        [NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:loaderView withObject:nil];
    }
}

// Stop indicator
- (void)stopIndicator
{
    if ([loaderView isAnimating])
    {
        [NSThread detachNewThreadSelector:@selector(stopAnimating) toTarget:loaderView withObject:nil];
    }
}

// Play current media
- (void)playCurrentMedia
{
    // out of range
    if (playIndex >= [listOfMedia count])
        return;
    Media *model = listOfMedia[playIndex];
    [self playMediaWithPath:model];
    [timelineCollectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:playIndex inSection:0];
    [timelineCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

// Fetch next item
- (void)fetchNextItem:(int)index
{
    // out of range
    if (index >= [listOfMedia count])
        return;
    // get media
    Media *model = listOfMedia[index];
    // video case
    if (model.mediaType == kMediaTypeVideo)
    {
        // check if downloaded before
        if ([model fetchLocalURL] == nil)
        {
            // download media video
            [[ConnectionManager sharedManager] downloadVideoFromURL:model.mediaLink progress:^(CGFloat progress)
             {
                 //NSLog(@"progress: %f", progress);
             }
                                                            success:^(NSURL *filePath)
             {
                 NSLog(@"file path:%@", filePath.absoluteString);
                 listOfMedia[index] = model;
             }
                                                            failure:^(NSError *error)
             {
                 NSLog(@"error");
             }];
        }
    }
    else// image case
    {
        UIImageView *tempImageView = [[UIImageView alloc] init];
        // load media
        [tempImageView sd_setImageWithURL:[NSURL URLWithString:model.mediaLink] placeholderImage:nil options:SDWebImageRefreshCached
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
         }];
    }
}

// Start playing image media
- (void)startPlayImage:(int)duration
{
    // reset the timer
    [playImageTimer invalidate];
    playImageTimer = nil;
    timeOut = duration;
    // run the timer
    NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(tickPlayImage:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sgn];
    [inv setTarget: self];
    [inv setSelector:@selector(tickPlayImage:)];
    playImageTimer = [NSTimer timerWithTimeInterval:1 invocation:inv repeats:YES];
    // run the timer
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:playImageTimer forMode:NSDefaultRunLoopMode];
    // fetch next item
    [self fetchNextItem:playIndex + 1];
}

// Stop play image
- (void)tickPlayImage:(NSTimer*)timer
{
    // count down 0
    if (timeOut <= 0)
    {
        [playImageTimer invalidate];
        playImageTimer = nil;
        // stop play image media
        [self stopPlayImage];
    }
    else// reduce counter
    {
        if (! isPaused)
            timeOut--;
    }
}

// Stop play image media
- (void)stopPlayImage
{
    [self didFinishMedia];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// used to simulate the effect of sliding the current media horizontally to show next
/// or prev timeline
/// when the user swipes the screen left of right the next timeline in this location will be loaded
- (void)didSwiepeOnScreen:(UIPanGestureRecognizer*)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        previousSwipeAmmount = 0.0f;
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        CGFloat playerConstantNewVal = 0;
        CGFloat swipeableViewConstantNewVal = 0;
        BOOL loadNext = NO;
        // if swipe distance was big enough
        // and we are not loadin another timeline, load next/prev video
        if(((hasPrevTimeline && movement.x > 140) || (hasNextTimeline && movement.x < -140))){ //
            playerConstantNewVal = - (self.view.frame.size.width) * (movement.x>0?-1:1);
            swipeableViewConstantNewVal = 0.0f;
            loadNext = YES;
        }else{
            playerConstantNewVal = 0.0f;
            swipeableViewConstantNewVal = (self.view.frame.size.width) * (movement.x>0?-1:1);;
        }
        
        // to make sure the swipableLayout wont appear above the other views
        //[self.view sendSubviewToBack:swipeabaleLayout];
        
        self.playerContainerXCenterConstraint.constant = playerConstantNewVal;
        self.swipeabaleLayoutXCenterConstraint.constant = swipeableViewConstantNewVal;
        self.fullImageContainerXCenterConstraint.constant = playerConstantNewVal;
        [self.view setNeedsUpdateConstraints];
        [self.swipeabaleLayout setNeedsUpdateConstraints];
        
        if(loadNext){
            [self showMediaSellectionFooter:NO fullHide:NO];
            [self showDetailsView:NO];
            [self showActionsButtons:NO];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            
            [self.view layoutIfNeeded];
            [self.swipeabaleLayout layoutIfNeeded];
        }
                         completion:^(BOOL finished)
         {
             //             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             //             });
             if(loadNext){
                 // clear the previous media view
                 [self.view sendSubviewToBack:playContainerView];
                 [self.view sendSubviewToBack:swipeabaleLayout];
                 bgImageView.image = nil;
                 [self.loaderView startAnimating];
                 // load next/prev timeline in this location
                 if(hasNextTimeline && movement.x < 0){
                     [self actionNextTimeline:nil];
                 }else if( hasPrevTimeline && movement.x > 0){
                     [self actionPrevTimeline:nil];
                 }
             }
             
             self.playerContainerXCenterConstraint.constant = 0;
             self.fullImageContainerXCenterConstraint.constant = 0;
             self.swipeabaleLayoutXCenterConstraint.constant = (self.view.frame.size.width);
         }];
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        //        if(isLoadingTimeline)
        //            return;
        
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        if(previousSwipeAmmount == 0){
            if(movement.x > 0){
                self.swipeabaleLayoutXCenterConstraint.constant = - (self.view.frame.size.width);
            }else{
                self.swipeabaleLayoutXCenterConstraint.constant = (self.view.frame.size.width);
            }
            [self.swipeabaleLayout setNeedsUpdateConstraints];
            [self.swipeabaleLayout layoutIfNeeded];
        }else{
            CGFloat changeAmmount = movement.x - previousSwipeAmmount;
            CGFloat swipeFactor = 0.9;
            
            // if there is no more data in the direction the user is tring to swipe to
            // we should make the swipe factor mutch smaller
            if((!hasNextTimeline && movement.x < 0) || (!hasPrevTimeline && movement.x > 0))
                swipeFactor = 0.0;
            
            self.swipeabaleLayoutXCenterConstraint.constant += changeAmmount * swipeFactor;
            self.playerContainerXCenterConstraint.constant += changeAmmount * swipeFactor;
            self.fullImageContainerXCenterConstraint.constant += changeAmmount * swipeFactor;
            
            [self.swipeabaleLayout setNeedsUpdateConstraints];
            [self.bgImageView setNeedsUpdateConstraints];
            [self.playContainerView setNeedsUpdateConstraints];
            
            [self.swipeabaleLayout layoutIfNeeded];
            [self.bgImageView layoutIfNeeded];
            [self.playContainerView layoutIfNeeded];
        }
        previousSwipeAmmount = movement.x;
    }
}

#pragma mark -
#pragma mark SSVideoPlayerDelegate
// Video player is ready
- (void)videoPlayerDidReadyPlay:(SSVideoPlayer *)videoPlayer
{
    // stop loader
    [self stopIndicator];
    
    // play video
    if (! isPaused){
        [player play];
    }
    // fetch next item
    [self fetchNextItem:playIndex + 1];
}

// Video player did begin play
- (void)videoPlayerDidBeginPlay:(SSVideoPlayer *)videoPlayer
{
}

// Video player did end play
- (void)videoPlayerDidEndPlay:(SSVideoPlayer *)videoPlayer
{
    [self didFinishMedia];
}

// Video player switch play
- (void)videoPlayerDidSwitchPlay:(SSVideoPlayer *)videoPlayer
{
    [self startIndicator];
}

// Video player failed
- (void)videoPlayerDidFailedPlay:(SSVideoPlayer *)videoPlayer
{
    [self stopIndicator];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Streaming Video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// Number of rows
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [listOfMedia count];
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"streamCollectionCell";
    StreamCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    // populate cell
    Media *model = listOfMedia[indexPath.row];
    BOOL isSelected = NO;
    if (indexPath.row == playIndex)
        isSelected = YES;
    [cell populateCellWithContent:model.thumbLink withSelected:isSelected];
    return cell;
}

#pragma mark -
#pragma mark - UICollectionViewDelegate
// Select item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Media *model = listOfMedia[indexPath.row];
    // play media
    playIndex = (int)indexPath.row;
    [self playMediaWithPath:model];
    [timelineCollectionView reloadData];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
    });
}

#pragma mark –
#pragma mark – UICollectionViewDelegateFlowLayout
// Item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(32, 64);
}

#pragma mark -
#pragma mark Actions Sheet
// Action sheet pressed button
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // facebook share
    if (buttonIndex == 0)
    {
        // check play index
        if (playIndex < [listOfMedia count])
        {
            Media *media = listOfMedia[playIndex];
            [[SocialManager sharedManager] facebookShareMedia:media withParent:self];
        }
    }
    // twitter share
    else if (buttonIndex == 1)
    {
        // check play index
        if (playIndex < [listOfMedia count])
        {
            Media *media = listOfMedia[playIndex];
            [[SocialManager sharedManager] twitterShareMedia:media withParent:self];
        }
    }
    // instagram share
    else if (buttonIndex == 2)
    {
        // check play index
        if (playIndex < [listOfMedia count])
        {
            // start loader
            [self.loaderView startAnimating];
            [self.view setUserInteractionEnabled:NO];
            Media *media = listOfMedia[playIndex];
            // share media on instagram
            [[SocialManager sharedManager] instagramShareMedia:media success:^
             {
                 // stop loader
                 [self.loaderView stopAnimating];
                 [self.view setUserInteractionEnabled:YES];
             }
                                                       failure:^(NSError *error, int errorCode)
             {
                 // stop loader
                 [self.loaderView stopAnimating];
                 [self.view setUserInteractionEnabled:YES];
                 // show notification error
                 if (errorCode == 0)
                     [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
                 else if (errorCode == 1)
                     [[AppManager sharedManager] showNotification:@"INSTAGRAM_ALERT_ERROR" withType:kNotificationTypeFailed];
             }];
        }
    }
    // copy link share
    else if (buttonIndex == 3)
    {
        // check play index
        if (playIndex < [listOfMedia count])
        {
            Media *media = listOfMedia[playIndex];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = media.mediaLink;
            // show notification success
            [[AppManager sharedManager] showNotification:@"TIMELINE_COPYLINK_SUCCESS" withType:kNotificationTypeSuccess];
        }
    }
}

#pragma mark -
#pragma mark Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"timelineProfileSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        [profileController setProfileWithTimeline: activeTimeline];
    }
    else if ([[segue identifier] isEqualToString:@"TimelineTimelinesCollectionSegue"])
    {
        Media *model = listOfMedia[playIndex];
        if (model != nil)
        {
            // pass the active user to profile page
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *timelinesController = (TimelinesCollectionController*)[navController viewControllers][0];
            if([model.event.objectId length] >0)
                [timelinesController setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:model.event];
            else
                [timelinesController setType:kCollectionTypeLocationTimelines withLocation:model.location withTag:nil withEvent:nil];
        }
    }
    else if ([[segue identifier] isEqualToString:@"timelineAddMentionSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        AddMentionController *addMentionController = (AddMentionController*)[navController viewControllers][0];
        [addMentionController setMentionListType:kTimelineTypeMention];
        [addMentionController setMentionType:kTimelineMentionToTimeline];
        [addMentionController setEnableGroups:YES];
    }
}

// Unwind mention segue
- (IBAction)unwindMentionSegue:(UIStoryboardSegue*)segue
{
    // pass the active game to details
    AddMentionController *detailsController = (AddMentionController*)segue.sourceViewController;
    NSMutableArray *mentionList = [detailsController getAllMentionedUsersList];
    if ([mentionList count] > 0){
        [self mentionProcess:mentionList];
    }
}

@end
