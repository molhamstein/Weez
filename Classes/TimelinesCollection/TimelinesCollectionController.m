//
//  TimelinesCollectionController.m
//  Weez
//
//  Created by Molham on 6/20/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelinesCollectionController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "Timeline.h"
#import "TimelineListCell.h"
#import "MediaCollectionViewCell.h"
#import "TimelineCollectionListCell.h"
#import "TimelinesCollectionReusableView.h"
#import "TimelineController.h"
#import "UIImageView+WebCache.h"
#import "ProfileController.h"
#import "AddMentionController.h"
#import "UserRelatedLocationsController.h"
#import "RecipientsListController.h"
#import "ChatController.h"
#import "CoordinatesDetailsController.h"
#import "ReportType.h"

@implementation TimelinesCollectionController

@synthesize timelinesTableView;
@synthesize timelinesCollectionView;
@synthesize coverImage;
@synthesize googleMapView;
@synthesize loaderView;
@synthesize location;
@synthesize event;
@synthesize locationId;
@synthesize selectedTimeline;
@synthesize playAllButton;
@synthesize locationNameLabel;
@synthesize locationFolowersTxtLabel;
@synthesize followButton;
@synthesize locationImage;
@synthesize locationInfoContainer;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize lblTotalMediaDuration;

- (void)viewDidLoad{
    [super viewDidLoad];
    // configure view
    [self configView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(animated){
        [self loadDataWithPage:0];
    }
}

- (void)configView
{
    shouldShareContent = NO;
    
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    if(collectionType == kCollectionTypeEventTimelines){
        // right button
        UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 19, 19);
        [rightButton setBackgroundImage:[UIImage imageNamed:@"navMentionIcon"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(mentionToEventAction) forControlEvents:UIControlEventTouchUpInside];
        // Initialize UIBarbuttonitem
        UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = barButton2;
    }
    
    if(collectionType == kCollectionTypeLocationTimelines || collectionType == kCollectionTypeEventTimelines){
        
        NSString *coverImageURL;
        NSString *profileImageURL;
        NSString *title;
        NSString *follwoersString;
        NSString *totalViewedDurationString;
        
        if(collectionType == kCollectionTypeLocationTimelines){
            title = location.name;
            coverImageURL = location.cover;
            profileImageURL = location.image;
            follwoersString = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",location.locationFollowers]];
            totalViewedDurationString = [[AppManager sharedManager] getViewedDuration:(int)location.totalMediaDuration];
        }else{ // event timelines
            title = event.name;
            coverImageURL = event.cover;
            profileImageURL = event.image;
            follwoersString = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",event.eventFollowers]];
            totalViewedDurationString = [[AppManager sharedManager] getViewedDuration:(int)event.totalMediaDuration];
        }
        
        // Header
        coverImage.contentMode = UIViewContentModeScaleAspectFill;
        coverImage.layer.masksToBounds = YES;
        [coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL] placeholderImage:nil options:SDWebImageRefreshCached
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {}];
        self.navigationItem.title = title;
        
        //Map
        [self drawLocationPin];
        
        // basic info
        locationNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
        locationFolowersTxtLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
        lblTotalMediaDuration.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
        
        locationNameLabel.text = title;
        locationFolowersTxtLabel.text = follwoersString;
        lblTotalMediaDuration.text = totalViewedDurationString;
        
        // load profile image
        TimelinesCollectionController __weak *weakSelf = self;
        [locationImage sd_setImageWithURL:[NSURL URLWithString:profileImageURL] placeholderImage:nil options:SDWebImageRefreshCached
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             weakSelf.locationImage.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImage.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
         }];
        
        // is user following this location/event
        if(collectionType == kCollectionTypeLocationTimelines){
            if([[[ConnectionManager sharedManager] userObject] isFollowingLocation:locationId]){
                [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
                [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
            }else{
                [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
                [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
            }
        }else{
            if([[[ConnectionManager sharedManager] userObject] isFollowingEvent:event.objectId]){
                [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
                [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
            }else{
                [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
                [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
            }
        }
        
        [[AppManager sharedManager] flipViewDirection:locationInfoContainer];
        
    }else if(collectionType == kCollectionTypeTagTimelines){
        self.navigationItem.title = tag.display;
        _headerHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"TIMELINES_COLLECTION_NO_TIMELINES"];
    [noResultView setHidden:YES];
    
    // not used for now
    playAllButton.hidden = YES;
    // Loader
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
}

- (void)refreshView{
    
    if(collectionType == kCollectionTypeLocationTimelines){
        locationNameLabel.text = location.name;
        locationFolowersTxtLabel.text = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",location.locationFollowers]];
        lblTotalMediaDuration.text = [[AppManager sharedManager] getViewedDuration:(int)location.totalMediaDuration];

        // is user following this location
        if([[[ConnectionManager sharedManager] userObject] isFollowingLocation:locationId]){
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
        }else{
            [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
            [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
        }
    }else if(collectionType == kCollectionTypeEventTimelines){
        locationNameLabel.text = event.name;
        locationFolowersTxtLabel.text = [[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FOLLOWERS"] stringByReplacingOccurrencesOfString:@"{count}" withString:[NSString stringWithFormat:@"%i",event.eventFollowers]];
        lblTotalMediaDuration.text = [[AppManager sharedManager] getViewedDuration:(int)event.totalMediaDuration];

        // is user following this event
        if([[[ConnectionManager sharedManager] userObject] isFollowingEvent:event.objectId]){
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
            [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
        }else{
            [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
            [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
        }
    }
}

- (void) setType:(AppCollectionType)type withLocation:(Location*)newLocation withTag:(Tag*)newTag withEvent:(Event *)newEvent
{
    self.location = newLocation;
    self.locationId = newLocation.objectId;
    self.event = newEvent;
    tag = newTag;
    collectionType = type;
}

- (void) drawLocationPin{
    
    Location* targetLocation;
    if(collectionType == kCollectionTypeLocationTimelines){
        targetLocation = location;
    }else{
        targetLocation = event.location;
    }
    GMSMarker *marker = [[GMSMarker alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(targetLocation.latitude, targetLocation.longitude);
    marker.position = coordinate;
    // zoom map camera slightly above the marker to make sure the marker is not hidden by the play icon
    CGPoint point = [googleMapView.projection pointForCoordinate:marker.position];
    point.y = point.y + 0.1; // 0.1 experimental number
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:[googleMapView.projection coordinateForPoint:point] zoom:13];
    [googleMapView setCamera:camera];
    
    marker.userData = targetLocation;
    marker.title = nil;
    marker.snippet = nil;
    marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
    marker.icon = [UIImage imageNamed:@"mapAnnotation"];
    marker.map = googleMapView;
}

#pragma mark -
#pragma mark SWTableViewCellDelegate
// Scrolling state
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath *indexPath = [timelinesTableView indexPathForCell:cell];
    UIButton *btn = [[cell rightUtilityButtons] objectAtIndex:index];
    NSInteger btnTag = btn.tag;
    
    switch (btnTag) {
        case CELL_SWIPE_ACTION_TAG_CHAT:
            selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"timelinesCollectionChatSegue" sender:self];
            break;
        case CELL_SWIPE_ACTION_TAG_REPORT:
            // report
            break;
        case CELL_SWIPE_ACTION_TAG_LOCATIONS:
            [self userRelatedLocationsActionWithIndex:(int)indexPath.row];
            break;
        case CELL_SWIPE_ACTION_TAG_MORE:
            selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
            [self showUserActionsSheetAction:selectedTimeline];
            break;
    }
    [cell hideUtilityButtonsAnimated:YES];
}

#pragma mark-
#pragma mark TableView
// Load data with page number
- (void)loadDataWithPage:(int)page
{
    loadingInProgress = YES;
    [noResultView setHidden:YES];
    // start animation
    if ([listOfTimelines count] == 0)
    {
        [timelinesTableView setHidden:YES];
        [timelinesCollectionView setHidden:YES];
        [loaderView setHidden:NO];
    }
    
    if(collectionType == kCollectionTypeLocationTimelines){
        NSString *lasUserId = @"";
        if(listOfTimelines != nil && page != 0){
            Timeline *lastTimeline = [listOfTimelines lastObject];
            lasUserId = lastTimeline.userId;
        }
        
        // get products list
        [[ConnectionManager sharedManager] getLocationTimelines:page LocationId:locationId lastId:lasUserId success:^(NSString *locationId, BOOL withPages, NSMutableArray *newFriends, NSMutableArray *newTimelines)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = withPages;
             [self refreshViewWithArrayOfFriends:newFriends andTimelines:newTimelines andPageNumber:page];
         }
                                                        failure:^(NSError *error)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = NO;
         }];
    }else if(collectionType == kCollectionTypeEventTimelines){
        NSString *lasUserId = @"";
        if(listOfTimelines != nil && page != 0){
            Timeline *lastTimeline = [listOfTimelines lastObject];
            lasUserId = lastTimeline.userId;
        }
        
        // get products list
        [[ConnectionManager sharedManager] getEventTimelines:page eventId:event.objectId lastId:lasUserId success:^(NSString *eventId, BOOL withPages, NSMutableArray* newFriends,NSMutableArray *newTimelines)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = withPages;
             [self refreshViewWithArrayOfFriends:newFriends andTimelines:newTimelines andPageNumber:page];
         }
                                                     failure:^(NSError *error)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = NO;
         }];
    }else{
        [[ConnectionManager sharedManager] getTagTimelines:page
                                                     TagId:(NSString*)tag.display
                                                   success:^(NSString *tagId, BOOL withPages, NSMutableArray *newTimelines)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = withPages;
             [self refreshViewWithArrayOfTimelines:newTimelines andPageNumber:page];
             
         }
                                                   failure:^(NSError *error)
         {
             // end refreshing
             [loaderView setHidden:YES];
             loadingInProgress = NO;
             isMoreData = NO;
             [self onLoadPageFailure:page];
         }];
    }
}

-(void) refreshViewWithArrayOfFriends:(NSMutableArray *)newFriends andTimelines:(NSMutableArray*) newTimelines andPageNumber:(int)page{
    
    [timelinesTableView setHidden:YES];
    // no more data
    if (!isMoreData)
    {
        // timelines exist
        if ([listOfTimelines count] > 0)
        {
            // get last index path
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[listOfTimelines count] inSection:0];
            // remove loading cell
            if ([timelinesCollectionView.indexPathsForVisibleItems containsObject:indexPath])
                [timelinesCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        }
    }
    if(page == 0){
        listOfTimelines = [[NSMutableArray alloc]init];
        listOfFriendsTimelines = [[NSMutableArray alloc]init];
    }
    // fill in data
    [listOfTimelines addObjectsFromArray:newTimelines];
    [listOfFriendsTimelines addObjectsFromArray:newFriends];
    isFriendSectionExist = [listOfFriendsTimelines count] > 0;
    // reload view
    if ([listOfTimelines count] > 0)
    {
        [timelinesCollectionView setHidden:NO];
        [timelinesCollectionView reloadData];
        // increase page
        currentPage = page;
    }
    else// no result
    {
        [timelinesCollectionView setHidden:YES];
        [noResultView setHidden:NO];
    }
    
    if ([listOfTimelines count] > 0)
        playAllButton.hidden = NO;
}

-(void) refreshViewWithArrayOfTimelines:(NSMutableArray*) newTimelines andPageNumber:(int)page{
    // no more data
    if (!isMoreData)
    {
        // timelines exist
        if ([listOfTimelines count] > 0)
        {
            // get last index path
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[listOfTimelines count] inSection:0];
            // remove loading cell
            if ([timelinesTableView.indexPathsForVisibleRows containsObject:indexPath])
                [timelinesTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if(page == 0){
        listOfTimelines = [[NSMutableArray alloc]init];
        listOfFriendsTimelines = [[NSMutableArray alloc]init];
    }
    // fill in data
    [listOfTimelines addObjectsFromArray:newTimelines];
    // reload table view
    if ([listOfTimelines count] > 0)
    {
        // show list
        [timelinesCollectionView setHidden:NO];
        [timelinesCollectionView reloadData];
        // increase page
        currentPage = page;
    }
    else// no result
    {
        [timelinesTableView setHidden:YES];
        [noResultView setHidden:NO];
    }
    
    if ([listOfTimelines count] > 0)
        playAllButton.hidden = NO;
}

-(void) onLoadPageFailure:(int) page
{
    // no more data
    if (!isMoreData)
    {
        // get last index path
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[listOfTimelines count] inSection:0];
        // remove loading cell
        if ([timelinesTableView.indexPathsForVisibleRows containsObject:indexPath])
            [timelinesTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    // reload table view
    if ([listOfTimelines count] > 0)
    {
        // show list
        [timelinesTableView setHidden:NO];
        [timelinesTableView reloadData];
        
        // alert user for no internet
        if (page == 0)
        {
            // show notification error
            [[AppManager sharedManager] showNotification:@"MSG_xECTION_ERROR" withType:kNotificationTypeFailed];
        }
    }
    else// no result
    {
        [timelinesTableView setHidden:YES];
    }
}

- (void)profileActionWithUser:(UIButton*)sender{
    int rowIndex = (int)sender.tag;
    selectedTimelineToViewProfile = [listOfTimelines objectAtIndex:rowIndex];
    [self performSegueWithIdentifier:@"TimelinesCollectionProfileSegue" sender:self];
}

- (void)userRelatedLocationsAction:(UIButton*)sender{
    int rowIndex = (int)sender.tag;
    [self userRelatedLocationsActionWithIndex:rowIndex];
}

- (void)userRelatedLocationsActionWithIndex:(int)timelineIndex{
    selectedTimelineToViewProfile = [listOfTimelines objectAtIndex:timelineIndex];
    [self performSegueWithIdentifier:@"timelinesCollectionUserRelatedLocationsSegue" sender:self];
}

#pragma mark -
#pragma mark Table view data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // load more cell
    if (indexPath.row == [listOfTimelines count])
        return CELL_LOAD_MORE_HEIGHT;
    // normal cell
    return CELL_TIMELINE_LIST_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // add cell for load more
    if (isMoreData)
        return [listOfTimelines count] + 1;
    return [listOfTimelines count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"locationDetailsListCell";
    static NSString *CellIdentifier2 = @"loadingMoreCell";
    // cell for loading more.
    if ((indexPath.row == [listOfTimelines count]) && isMoreData)
    {
        UITableViewCell *loadMoreCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(timelinesTableView.frame.size.width/2 - 22, 0, 44, 44);
        [activityIndicator startAnimating];
        if (loadMoreCell == nil)
        {
            loadMoreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            loadMoreCell.frame = CGRectZero;
        }
        loadMoreCell.backgroundColor = [UIColor clearColor];
        [loadMoreCell.contentView addSubview:activityIndicator];
        loadMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return loadMoreCell;
    }
    // list cell
    // timeline list cell
    TimelineListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Timeline *timelineObj = [listOfTimelines objectAtIndex:indexPath.row];
    [cell populateCellWithContent:timelineObj];
    cell.mediaButton.hidden = YES;
    // open profile button
    cell.profileButton.tag = indexPath.row;
    [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell initSwipeActions:self];
    return cell;
}

// Will display cell at index
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // load more data
    if ((indexPath.row == [listOfTimelines count]) && isMoreData)
    {
        // loading process
        if (!loadingInProgress)
            [self loadDataWithPage:currentPage + 1];
    }
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // load more cell
    if ((indexPath.row == [listOfTimelines count]) && isMoreData)
        return;
    selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"TimelinesCollectionTimelineSegue" sender:self];
    // deselect row for next touch
    [timelinesTableView deselectRowAtIndexPath:indexPath animated:NO];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"TimelinesCollectionTimelineSegue"])
    {
        // pass the active user to profile page
        TimelineController *timelineController = segue.destinationViewController;
        if(collectionType == kCollectionTypeEventTimelines)
            [timelineController setTimelineObject:selectedTimeline withLocation:nil orEvent:event];
        else
            [timelineController setTimelineObject:selectedTimeline withLocation:location orEvent:nil];
    }else if([[segue identifier] isEqualToString:@"TimelinesCollectionProfileSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = [navController viewControllers][0];
        [profileController setProfileWithTimeline:selectedTimelineToViewProfile];
        selectedTimelineToViewProfile = nil;
    }else if([[segue identifier] isEqualToString:@"timelinesCollectionAddMentionSegue"]){ /// used to mention someone to an event
        UINavigationController *navController = [segue destinationViewController];
        AddMentionController *addMentionController = (AddMentionController*)[navController viewControllers][0];
        addMentionController.selectionMode = MULTIPLE;
        [addMentionController setMentionListType:kTimelineTypeMention];
        [addMentionController setMentionType:kEventMentionToTimelineCollection];
        [addMentionController setEnableGroups:YES];
    }else if([segue.identifier isEqualToString:@"timelinesCollectionUserRelatedLocationsSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        UserRelatedLocationsController *locationsController = (UserRelatedLocationsController*)[navController viewControllers][0];
        [locationsController setUserId:selectedTimelineToViewProfile.userId];
        selectedTimelineToViewProfile = nil;
    }else if ([[segue identifier] isEqualToString:@"TimelinesCollectionAddMensionSegue"]){ // used to send location or event as message to single user
        
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        AddMentionController *addMentionController = (AddMentionController*)[navController viewControllers][0];
        addMentionController.selectionMode = SINGLE;
        [addMentionController setMentionListType:kTimelineTypeGroup];
        [addMentionController setMentionType:kEventMentionToChat];
        [addMentionController setEnableGroups:YES];
    }else if ([[segue identifier] isEqualToString:@"timelinesCollectionChatSegue"]){
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        // submit location as a message to the picked group or user
        if(shouldShareContent){
            // pass selected reciptiant to chat controller
            if(selectedGroupToSubmit){
                Group *grp = [Group alloc];
                grp.objectId = selectedGroupToSubmit.objectId;
                grp.name = selectedGroupToSubmit.name;
                [chatController setGroup:grp withParent:nil];
            }else if(selectedFriendToSubmit){
                User *timeline = [User alloc];
                timeline.objectId = selectedFriendToSubmit.objectId;
                timeline.username = selectedFriendToSubmit.displayName;
                [chatController setPeerUser:timeline];
            }
            
            [chatController setLocationToshareAsMessage:location];
            [chatController setEventToshareAsMessage:event];
        }else{ // open chat with the selected user timeline
            [chatController setTimeline:selectedTimeline];
            selectedTimeline = nil;
        }
    }else if([[segue identifier] isEqualToString:@"timelinesCollectionCoordinatesDetailsSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        CoordinatesDetailsController *coordDetailsController = (CoordinatesDetailsController*)[navController viewControllers][0];
        if(event)
            [coordDetailsController setCoordinatesLat:event.location.latitude andLong:event.location.longitude];
        else
            [coordDetailsController setCoordinatesLat:location.latitude andLong:location.longitude];
    }
}

#pragma mark -
#pragma mark Nav
// Cancel action
- (void)cancelAction{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playAllAction{
    if([listOfTimelines count] > 0){
        selectedTimeline = [listOfTimelines firstObject];
        [self performSegueWithIdentifier:@"TimelinesCollectionTimelineSegue" sender:self];
    }
}

- (IBAction)showUserActionsSheetAction:(Timeline*)timeline{
    
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList;
    if([timeline isFollowing])
    actionList = @[[[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_LOCATIONS"],
                   [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_UNFOLLOW"],
                   [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_REPORT"]
                   ];
    else
    actionList = @[[[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_LOCATIONS"],
                   [[AppManager sharedManager] getLocalizedString:@"HOME_USER_ACTIONS_FOLLOW"],
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
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kSheetUserActions){
        if (buttonIndex == 0){ // user related locations
            [self performSegueWithIdentifier:@"timelinesCollectionUserRelatedLocationsSegue" sender:self];
            selectedTimelineToViewProfile = selectedTimeline;
            selectedTimeline = nil;
        }else if (buttonIndex == 1){ // follow
            [self followActionUser:selectedTimeline.userId];
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

// Follow user
-(IBAction)followActionUser:(NSString*)userId{
    [[ConnectionManager sharedManager].userObject followFriend:userId];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:userId success:^(void){
        // notify about timeline changes
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
    }
                                          failure:^(NSError * error){}];
}

#pragma mark -
#pragma mark mention in event
- (void)mentionToEventAction
{
    [self performSegueWithIdentifier:@"timelinesCollectionAddMentionSegue" sender:self];
    
}

- (IBAction)unwindEventMentionsSegue:(UIStoryboardSegue*)segue
{
    // pass the active game to details
    AddMentionController *detailsController = (AddMentionController*)segue.sourceViewController;
    NSMutableArray *mentionList = [detailsController getAllMentionedUsersList];
    if ([mentionList count] > 0){
        [self mentionToEvent:mentionList];
    }
}

- (void)mentionToEvent:(NSMutableArray *) recepients{
    
    [[ConnectionManager sharedManager] mentionToEvent:event recepients:recepients success:^()
     {
         // end refreshing
         [loaderView setHidden:YES];
         [[AppManager sharedManager] showNotification:@"TIMELINES_COLLECTION_MENTION_SUCCESS"  withType:kNotificationTypeSuccess];
     }
                                              failure:^(NSError *error)
     {
         // end refreshing
         [loaderView setHidden:YES];
         [[AppManager sharedManager] showNotification:@"TIMELINES_COLLECTION_MENTION_FAILED" withType:kNotificationTypeFailed];
     }];
}

#pragma mark -
#pragma mark follow
// Follow action
- (IBAction)followAction:(id)sender{
    [followButton setEnabled:NO];
    if(collectionType == kCollectionTypeLocationTimelines)
        [[ConnectionManager sharedManager].userObject followLocation:locationId];
    else
        [[ConnectionManager sharedManager].userObject followEvent:event.objectId];
    // animate the pressed voted image
    followButton.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         followButton.alpha = 0.0;
         followButton.transform = CGAffineTransformScale(followButton.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         // follow/unfollow this user
         [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
         [followButton setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
         if ([location isFollowing])
         {
             [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
             [followButton setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
         }
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              followButton.alpha = 1.0;
              followButton.transform = CGAffineTransformScale(followButton.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {}];
     }];
    // follow/unfollow location
    if(collectionType == kCollectionTypeLocationTimelines)
        [[ConnectionManager sharedManager] followLocation:locationId success:^(void)
         {
             // notify about timeline changes
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
             [[ConnectionManager sharedManager] getCurrentUser:^{
                 User *me = [[ConnectionManager sharedManager] userObject];
                 if([me isFollowingLocation:locationId]){
                     location.locationFollowers = location.locationFollowers +1;
                 }else if(location.locationFollowers > 0){
                     location.locationFollowers = location.locationFollowers -1;
                 }
                 [self refreshView];
                 [followButton setEnabled:YES];
             } failure:^(NSError *error) {
                 [followButton setEnabled:YES];
             }];
         }
                                                  failure:^(NSError * error)
         {
             [followButton setEnabled:YES];
             [self refreshView];
         }];
    else
        [[ConnectionManager sharedManager] followEvent:event.objectId success:^(void)
         {
             // notify about timeline changes
             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
             [[ConnectionManager sharedManager] getCurrentUser:^{
                 User *me = [[ConnectionManager sharedManager] userObject];
                 if([me isFollowingEvent:event.objectId]){
                     event.eventFollowers = event.eventFollowers +1;
                 }else if(event.eventFollowers > 0){
                     event.eventFollowers = event.eventFollowers -1;
                 }
                 [self refreshView];
                 [followButton setEnabled:YES];
             } failure:^(NSError *error) {
                 [followButton setEnabled:YES];
             }];
         }
                                               failure:^(NSError * error)
         {
             [followButton setEnabled:YES];
             [self refreshView];
         }];
}
#pragma mark -
#pragma mark share

// Unwind mention segue
- (IBAction)unwindMentionSegue:(UIStoryboardSegue*)segue
{
    AddMentionController *detailsController = (AddMentionController*)segue.sourceViewController;
    selectedFriendToSubmit = [detailsController getFirstSelectedFollower];
    selectedGroupToSubmit = [detailsController getFirstSelectedGroup];
    if(selectedGroupToSubmit || selectedFriendToSubmit){
        shouldShareContent = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.9 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"timelinesCollectionChatSegue" sender:nil];
        });
    }
}

#pragma mark -
#pragma mark showOnMap
- (IBAction) showOnMap{
    // show location in Google maps app
    // if not present show location in coordinates viewController
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
        float lat;
        float lng;
        if(event){
            lat = event.location.latitude;
            lng = event.location.longitude;
        }else{
            lat = location.latitude;
            lng = location.longitude;
        }
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f ,%f", lat,lng]]];
        NSString *latlong = [NSString stringWithFormat:@"%f,%f",lat,lng];
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=&daddr=%@",
                         [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }else{
        [self performSegueWithIdentifier:@"timelinesCollectionCoordinatesDetailsSegue" sender:self];
    }
}

#pragma - mark
#pragma - mark UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return isFriendSectionExist ? 2 :1;
}

// Number of items
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(isFriendSectionExist && section == 0)
        return [listOfFriendsTimelines count];
    return isMoreData?[listOfTimelines count]+1:[listOfTimelines count];
}

//section header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSString *headerViewId = @"sectionHeaderView";
    TimelinesCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewId forIndexPath:indexPath];
    
    NSString *title = @"";
    if(isFriendSectionExist && indexPath.section == 0)
        title = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_FRIENDS"];
    else
        title = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_ALL"];
    
    [header setTitle:title];
    return header;
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"locationDetailsCollectionCell";
    static NSString *CellIdentifier2 = @"locationDetailsListCell";
    static NSString *CellIdentifier3 = @"loadingMoreCell";
    if(isFriendSectionExist && indexPath.section == 0)
    {
        TimelineCollectionListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier2 forIndexPath:indexPath];
        Timeline *media = [listOfTimelines objectAtIndex:indexPath.item];
        [cell populateCellWithContent:media];
        [cell initSwipeActions:self];
        cell.moreButton.tag = indexPath.item;
        [cell.moreButton addTarget:self action:@selector(swipeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else
    {
        // cell for loading more.
        if(indexPath.item == [listOfTimelines count] && isMoreData)
        {
            UICollectionViewCell *loadMoreCell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier3 forIndexPath:indexPath];
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            activityIndicator.frame = CGRectMake( loadMoreCell.frame.origin.x + loadMoreCell.frame.size.width/2 - 22,loadMoreCell.frame.origin.x + loadMoreCell.frame.size.height/2 - 22, 44, 44);
            [activityIndicator startAnimating];
            if (loadMoreCell == nil)
            {
                loadMoreCell = [[UICollectionViewCell alloc] init];
                loadMoreCell.frame = CGRectZero;
            }
            loadMoreCell.backgroundColor = [UIColor clearColor];
            [loadMoreCell.contentView addSubview:activityIndicator];
            return loadMoreCell;
            
        }
        MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Timeline *media = [listOfTimelines objectAtIndex:indexPath.item];
        [cell populateSquareCellWithTimeline:media];
        cell.layer.borderWidth = 0.0;
        return cell;
    }
}

// Will display cell at index
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // load more data
    if ((indexPath.item == [listOfTimelines count]) && isMoreData)
    {
        // loading process
        if (!loadingInProgress)
            [self loadDataWithPage:currentPage + 1];
    }
}

#pragma mark -
#pragma mark - UICollectionViewDelegate
// Select item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //friends section
    if(isFriendSectionExist && indexPath.section == 0)
    {
        selectedTimeline = [listOfFriendsTimelines objectAtIndex:indexPath.item];
    }
    else//all section
    {
    // load more cell
    if ((indexPath.item == [listOfTimelines count]) && isMoreData)
        return;
        
    selectedTimeline = [listOfTimelines objectAtIndex:indexPath.item];
    }
    [self performSegueWithIdentifier:@"TimelinesCollectionTimelineSegue" sender:self];
    // deselect row for next touch
    [timelinesTableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void) swipeButtonAction:(UIButton *)sender
{
    
    TimelineCollectionListCell *cell = (TimelineCollectionListCell*)[[[sender superview] superview]superview];
    if([cell respondsToSelector:@selector(hideRevealViewAnimated:)])
       [cell hideRevealViewAnimated:YES];

    int rowIndex = (int)sender.tag;
    selectedTimeline = [listOfFriendsTimelines objectAtIndex:rowIndex];
    if(selectedTimeline.timelineType != kTimelineTypeGroup)
    {
        [self showUserActionsSheetAction:selectedTimeline];
    }
    else
    {
        [self performSegueWithIdentifier:@"timelinesCollectionChatSegue" sender:self];
    }
}

#pragma mark –
#pragma mark – UICollectionViewDelegateFlowLayout
// Item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    if(isFriendSectionExist && indexPath.section == 0)
        return CGSizeMake(screenWidth,85);
    else
        return CGSizeMake(screenWidth/3,screenWidth/3);
}



@end
