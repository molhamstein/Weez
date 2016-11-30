//
//  MapController.m
//  Weez
//
//  Created by Molham on 6/14/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "MapController.h"
#import "Location.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "TimelineController.h"
#import "LocatoinAnnotation.h"
#import "TimelinesCollectionController.h"
#import "WeezCollectionController.h"
#import "EventListCell.h"
#import "AddMentionController.h"

@implementation MapController

//@synthesize mapView;
@synthesize googleMapView;
@synthesize listOfLocations;
@synthesize usersTableView;
@synthesize selectedLocation;
@synthesize listOfEventsinSelectedLocation;
@synthesize viewDetailsContainer;
@synthesize loaderView;
@synthesize trendingLocationsButton;
@synthesize followedLocationsButton;
@synthesize actionOverlayCalloutView;
@synthesize mapViewTypeToggleButton;

CGFloat infoWindowHeight = 95;
CGFloat infoWindowWidth = 160;
CGFloat anchorSize = 20;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // configure view
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (animated){
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:[AppManager sharedManager].currenttUserLocation.coordinate zoom:13];
        googleMapView.myLocationEnabled = YES;
        googleMapView.settings.myLocationButton = YES;
        userMovedMap = YES;
        [googleMapView setCamera:camera];
        [self trendingAction:nil];
//        [mapView setCenterCoordinate:[AppManager sharedManager].currenttUserLocation.coordinate animated:YES];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//
//        });
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didMoveMap:(UIGestureRecognizer*)gestureRecognizer {
   if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
       userMovedMap = YES;
    }
}

- (void)didSwiepeTable:(UIPanGestureRecognizer*)gestureRecognizer {
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        //if we are at the first view in the tableview and the user swiped up then expand the details view
        if((detailViewStatus == detailsViewStatusMinimized || detailViewStatus == detailsViewStatusClosed)
           && movement.y < 0){
            
            [self openDetailsView];
            usersTableView.scrollEnabled = YES;
            detailViewStatus = detailsViewStatusExpanded;
        }else if(detailViewStatus == detailsViewStatusExpanded && movement.y > 130){
            
            self.detailsViewBottomConstraint.constant = - (viewDetailsContainer.frame.size.height - CELL_LOCATION_HEIGHT);
            [self.viewDetailsContainer setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2 animations:^{
                [self.viewDetailsContainer layoutIfNeeded];
            }];
            //[usersTableView scrollsToTop];
            usersTableView.scrollEnabled = NO;
            detailViewStatus = detailsViewStatusMinimized;
        }
    }
}

- (void)configView{
    
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_MAP_TITLE"];
    
    //grid button
    UIButton *gridButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    gridButton.frame = CGRectMake(0, 0, 16, 14);
    [gridButton setBackgroundImage:[UIImage imageNamed:@"btnGrid"] forState:UIControlStateNormal];
    [gridButton addTarget:self action:@selector(showFollowGrid:) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *gridBarButton = [[UIBarButtonItem alloc] initWithCustomView:gridButton];
    self.navigationItem.rightBarButtonItem = gridBarButton;
    //hide the button
    [self.navigationItem.rightBarButtonItem.customView setHidden:YES];

    // Header
    CGFloat spacing = 10; // the amount of spacing to appear between image and title
    trendingLocationsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    trendingLocationsButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    followedLocationsButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    followedLocationsButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
    
    trendingLocationsButton.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    followedLocationsButton.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    
    [followedLocationsButton setTitle:[[AppManager sharedManager] getLocalizedString:@"MAP_FOLLOWED"] forState:UIControlStateNormal];
    [trendingLocationsButton setTitle:[[AppManager sharedManager] getLocalizedString:@"MAP_TRENDING"] forState:UIControlStateNormal];
    
    //loader
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    
    // init map
    //mapView.showsUserLocation = NO;
    googleMapView.delegate = self;
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveMap:)];
    UIPinchGestureRecognizer *pinchRec = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveMap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveMap:)];
    doubleTap.numberOfTapsRequired = 2;
    [panRec setDelegate:self];
    [pinchRec setDelegate:self];
    [doubleTap setDelegate:self];
    [self.googleMapView addGestureRecognizer:panRec];
    [self.googleMapView addGestureRecognizer:pinchRec];
    [self.googleMapView addGestureRecognizer:doubleTap];
    
    // init tableView
    self.detailsViewBottomConstraint.constant = - viewDetailsContainer.frame.size.height;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [self.viewDetailsContainer layoutIfNeeded];
    detailViewStatus = detailsViewStatusClosed;
    usersTableView.bounces = NO;
    
    [[AppManager sharedManager] addViewDropShadow:viewDetailsContainer withOpacity:0.2];
    //    UISwipeGestureRecognizer *gestRecUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiepeTable:)];
    //    gestRecUp.direction =  UISwipeGestureRecognizerDirectionUp;
    //    [gestRecUp setDelegate:self];
    //    gestRecUp.cancelsTouchesInView = NO;
    //
    //    UISwipeGestureRecognizer *gestRecDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiepeTable:)];
    //    gestRecDown.direction = UISwipeGestureRecognizerDirectionDown;
    //    [gestRecDown setDelegate:self];
    //    gestRecDown.cancelsTouchesInView = NO;
    
    UIPanGestureRecognizer *gestRecUp = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwiepeTable:)];
    [gestRecUp setDelegate:self];
    gestRecUp.cancelsTouchesInView = NO;
    
    [usersTableView addGestureRecognizer:gestRecUp];
    //[usersTableView addGestureRecognizer:gestRecDown];
    
}

// Cancel action
- (void)cancelAction{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onDone{
    // save selected location
    [self performSegueWithIdentifier:@"unwindLocationSegue" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark Data

- (void)refreshMapData{
    
    GMSVisibleRegion vr = googleMapView.projection.visibleRegion;
    double centerLat = googleMapView.camera.target.latitude;
    double centerLon = googleMapView.camera.target.longitude;
    
    //double centerLon = vr.farLeft.longitude + ( vr.farRight.longitude - vr.farLeft.longitude)/2;
    CLLocation *centerLoc = [[CLLocation alloc]initWithLatitude:centerLat longitude:centerLon];
    CLLocation *farLeftLoc = [[CLLocation alloc]initWithLatitude:vr.farLeft.latitude longitude:vr.farLeft.longitude];
    CLLocationDistance distance = [centerLoc distanceFromLocation:farLeftLoc];
    [self loadDataWithLocationsLat:centerLat andLong:centerLon andRadius:distance];
    
}

- (void)loadDataWithLocationsLat:(float)lat andLong:(float) longitude andRadius:(double)radius{
    if(loadingInProgress)
        return;
    [self startIndicator];
    loadingLocationsInProgress = YES;
    // request data from the api
    [[ConnectionManager sharedManager] getTrendingLocationsListNear:lat long:longitude withRadius:radius
    success:^(NSMutableArray *locations) {
        self.listOfLocations = locations;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopIndicator];
            loadingLocationsInProgress = NO;
            [self reloadMapAnnotations];
        });
    } failure:^(NSError *error) {
        [self stopIndicator];
        loadingLocationsInProgress = NO;
    }];
}

- (void) loadFollowedLocations{
    [self startIndicator];
    loadingLocationsInProgress = YES;
    // request data from the api
    [[ConnectionManager sharedManager] getFavoriteLocations:^(NSMutableArray *favLocations) {
        [self stopIndicator];
        loadingLocationsInProgress = NO;
        if(currentMode == MapModeFollowedLocations){
            self.listOfLocations = favLocations;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadMapAnnotations];
            });
        }
    } failure:^(NSError *error) {
        [self stopIndicator];
        loadingLocationsInProgress = NO;
    }];
}

- (void) showFollowGrid :(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"mapWeezCollectionSegue" sender:nil];
}

// Load timelines of selected location with page number
- (void)loadLocationTimelinesWithPage:(int)page
{
    if(selectedLocation == nil)
        return;
    
    loadingTimelinesInProgress = YES;
    // start animation
//    if ([listOfEventsinSelectedLocation count] == 0){
//        [usersTableView setHidden:YES];
//        //[loaderView setHidden:NO];
//    }
    
    NSString *lasUserId = @"";
    if(listOfEventsinSelectedLocation != nil){
        Timeline *lastTimeline = [listOfEventsinSelectedLocation lastObject];
        lasUserId = lastTimeline.userId;
    }
    
    // get products list
    [[ConnectionManager sharedManager] getLocationTimelines:page LocationId:selectedLocation.objectId lastId:lasUserId success:^(NSString *locationId, BOOL withPages, NSMutableArray *newFriends, NSMutableArray *newTimelines){
        // end refreshing
        //[loaderView setHidden:YES];
        
        loadingInProgress = NO;
        isMoreData = withPages;
        loaderView.hidden = YES;
        
        // if user diselected the location or selected a different location while we were tring to get the data
        if(selectedLocation == nil || ![selectedLocation.objectId isEqualToString:locationId]){
            return ;
        }
        
        // no more data
        if (!isMoreData){
            // timelines exist
            if ([listOfEventsinSelectedLocation count] > 0){
                // get last index path
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[listOfEventsinSelectedLocation count] inSection:0];
                // remove loading cell
                if ([usersTableView.indexPathsForVisibleRows containsObject:indexPath])
                    [usersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        if(page == 0){
            listOfEventsinSelectedLocation = [[NSMutableArray alloc]init];
        }
        // fill in data
        [listOfEventsinSelectedLocation addObjectsFromArray:newTimelines];
        // reload table view
        if ([listOfEventsinSelectedLocation count] > 0){
            // show list
            // [usersTableView setHidden:NO];
            if(page == 0)
                [self onTimelinesListRecieved];
            else
                [usersTableView reloadData];
            // increase page
            currentPage = page;
        }
//        else{
//            [usersTableView setHidden:YES];
//        }
        
    } failure:^(NSError *error){
        // end refreshing
        [loaderView setHidden:YES];
        loadingTimelinesInProgress = NO;
        isMoreData = NO;
        // no more data
//        if (!isMoreData){
//            // get last index path
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[listOfEventsinSelectedLocation count] inSection:0];
//            // remove loading cell
//            if ([usersTableView.indexPathsForVisibleRows containsObject:indexPath])
//                [usersTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        }
        // reload table view
        if ([listOfEventsinSelectedLocation count] > 0){
            // show list
            [self onTimelinesListRecieved];
        }
        
           // alert user for no internet
        if (page == 0){
            // show notification error
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
        }
    }];
}

- (void) onTimelinesListRecieved{
    [usersTableView reloadData];
    [usersTableView setContentOffset:CGPointZero animated:YES];
    
    usersTableView.scrollEnabled = YES;
    
    CGFloat newConstraintConstant = 0;
    if(detailViewStatus == detailsViewStatusClosed || detailViewStatus == detailsViewStatusExpanded){
        // make the details view as hight as the visible items in it
        newConstraintConstant = - (viewDetailsContainer.frame.size.height - (CELL_LOCATION_HEIGHT *[listOfEventsinSelectedLocation count]));
        if( newConstraintConstant > 0 )
            newConstraintConstant = 0;
        detailViewStatus = detailsViewStatusExpanded;
    }else if(detailViewStatus == detailsViewStatusMinimized){
        newConstraintConstant = - (viewDetailsContainer.frame.size.height - CELL_LOCATION_HEIGHT);
        detailViewStatus = detailsViewStatusMinimized;
    }
    
    self.detailsViewBottomConstraint.constant = newConstraintConstant;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
}

#pragma mark -
#pragma mark Map
// Reload map annotations
- (void)reloadMapAnnotations{
    
    [googleMapView clear];
    // loop overall providers
    for (int i = 0; i < [listOfLocations count]; i++){
        Location *providerObj = [listOfLocations objectAtIndex:i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(providerObj.latitude, providerObj.longitude);
        marker.title = providerObj.name;
        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
        marker.snippet = nil;
        marker.icon = [UIImage imageNamed:@"mapAnnotation"];
        marker.userData = providerObj;
        marker.map = googleMapView;
    }
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    return [self infoWindwForMarker:marker];
}

- (UIView *) infoWindwForMarker:(GMSMarker *)marker{
    int contentPad = 6;
    int anchorSize = 20;
    
    [self.actionOverlayCalloutView removeFromSuperview];
    UIView *calloutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoWindowWidth, infoWindowHeight)];
    
    float offset = anchorSize * M_SQRT2;
    CGAffineTransform rotateBy45Degrees = CGAffineTransformMakeRotation(M_PI_4);
    UIView *arrow = [[UIView alloc] initWithFrame:CGRectMake((infoWindowWidth - anchorSize)/2.0, infoWindowHeight - offset, anchorSize, anchorSize)];
    arrow.transform = rotateBy45Degrees;
    arrow.backgroundColor = [UIColor whiteColor];
    [calloutView addSubview:arrow];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoWindowWidth, infoWindowHeight - offset/2)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    
    contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentView.layer.borderWidth = 1.0f;
    
    self.actionOverlayCalloutView =
    [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:contentView]]; //hack to copy a view...
    self.actionOverlayCalloutView.backgroundColor = [UIColor whiteColor];
    self.actionOverlayCalloutView.layer.cornerRadius = 5;
    NSMutableArray *falseButtons = [NSMutableArray array];
    NSMutableArray *actionButtons = [NSMutableArray array];
    
    // fill data
    Location *markerLocationModel = marker.userData;
    
    CGRect imgFrame = CGRectMake(contentPad/2, contentPad/2, 60-(6+contentPad*2), 60-(6+contentPad*2));
    CGRect titleFrame = CGRectMake(contentPad/2 + imgFrame.origin.x + imgFrame.size.width, imgFrame.origin.y, infoWindowWidth - (imgFrame.size.width + contentPad + 6), 40);
//    if([AppManager sharedManager].appLanguage == kAppLanguageAR){
//        CGFloat tempX = imgFrame.origin.x;
//        titleFrame.origin.x = tempX;
//        imgFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + contentPad/2;
//    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    [titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontCellNumber]];
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.text = [marker title];
    titleLabel.backgroundColor = [UIColor whiteColor];
    //titleLabel.textAlignment = NSTextAlignment;
    titleLabel.numberOfLines = 2;
    
    // update accesrossy view
    UIImageView *imgLocation = [[UIImageView alloc] initWithFrame:imgFrame];
    imgLocation.backgroundColor = [UIColor whiteColor];
    
    __weak UIImageView *weakImgLocation = imgLocation;
    [imgLocation sd_setImageWithURL:[NSURL URLWithString:markerLocationModel.image] placeholderImage:nil options:SDWebImageRefreshCached
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         weakImgLocation.image = [[AppManager sharedManager] convertImageToCircle:weakImgLocation.image clipToCircle:YES withDiamter:100 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
     }];
    
    [self.actionOverlayCalloutView addSubview:titleLabel];
    [self.actionOverlayCalloutView addSubview:imgLocation];
    
    // timelines count
    UIButton *timelinesCount = [[UIButton alloc] init];
    [timelinesCount setImage:[UIImage imageNamed:@"timelinesCountIcon"] forState:UIControlStateNormal];
    timelinesCount.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    [timelinesCount setTitleColor:[[AppManager sharedManager] getColorType:kAppColorRed] forState:UIControlStateNormal];
    [timelinesCount setFrame: CGRectMake(titleFrame.origin.x + titleFrame.size.width, imgFrame.origin.y + imgFrame.size.height + 4, 60-(6+contentPad*2), 22)];
    [timelinesCount setTitle:[NSString stringWithFormat:@"%d", markerLocationModel.timelinesCount] forState:UIControlStateNormal];
    [timelinesCount setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 2)];
    timelinesCount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [timelinesCount setBackgroundColor:[UIColor greenColor]];
//    [imgLocation setBackgroundColor:[UIColor yellowColor]];
//    [titleLabel setBackgroundColor:[UIColor blueColor]];
    
    // adding buttons
    // Play button
    UIButton *playButton = [[UIButton alloc] init];
    [playButton setImage:[UIImage imageNamed:@"playLocationIcon"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playLocationAction:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setFrame:CGRectMake(contentPad/2 , imgFrame.origin.y + imgFrame.size.height +5, 34, 22)];
    // Follow button
    UIButton *followButton = [[UIButton alloc] init];
    [followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    [followButton setFrame:CGRectMake(playButton.frame.origin.x + playButton.frame.size.width + 26, playButton.frame.origin.y, 34, 22)];
    if([[[ConnectionManager sharedManager] userObject] isFollowingLocation:markerLocationModel.objectId]){
        [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateHighlighted];
        [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateDisabled];
    }else{
        [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateNormal];
        [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateHighlighted];
        [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateDisabled];
    }
    // location details button
    UIButton *infoButton = [[UIButton alloc] init];
    [infoButton setImage:[UIImage imageNamed:@"locationInfoIcon"] forState:UIControlStateNormal];
    [infoButton addTarget:self action:@selector(locationInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    [infoButton setFrame:CGRectMake(followButton.frame.origin.x + followButton.frame.size.width + 26, followButton.frame.origin.y, 34, 22)];
    
    [self.actionOverlayCalloutView addSubview:playButton];
    [self.actionOverlayCalloutView addSubview:followButton];
    [self.actionOverlayCalloutView addSubview:infoButton];
    //[self.actionOverlayCalloutView addSubview:timelinesCount];
    
    [[AppManager sharedManager] flipViewDirection:self.actionOverlayCalloutView];
    
    int buttonWidth = contentView.frame.size.width / [falseButtons count];
    int currentOffset = 0;
    for (int i=0; i<falseButtons.count; i++) {
        UIButton *falseButton = [falseButtons objectAtIndex:i];
        UIButton *activableButton = [actionButtons objectAtIndex:i];
        [falseButton setFrame:CGRectMake(currentOffset, 0, buttonWidth, contentView.frame.size.height)];
        currentOffset += buttonWidth;
        activableButton.frame = falseButton.frame;
        [activableButton setTitle:@"" forState:UIControlStateNormal];
        [self.actionOverlayCalloutView addSubview:activableButton];
        [contentView addSubview:falseButton];
    }
    [calloutView addSubview:contentView];
    
    CLLocationCoordinate2D anchor = [self.googleMapView.selectedMarker position];
    CGPoint point = [self.googleMapView.projection pointForCoordinate:anchor];
    point.y -= self.googleMapView.selectedMarker.icon.size.height + offset/2 + (infoWindowHeight - offset/2)/2;
    self.actionOverlayCalloutView.center = point;
    
    [self.googleMapView addSubview:self.actionOverlayCalloutView];
    return calloutView;

}

- (void)mapView:(GMSMapView *)pMapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (pMapView.selectedMarker != nil && self.actionOverlayCalloutView.superview) {
        CLLocationCoordinate2D anchor = [self.googleMapView.selectedMarker position];
        CGPoint point = [self.googleMapView.projection pointForCoordinate:anchor];
        float offset = anchorSize * M_SQRT2;
        point.y -= self.googleMapView.selectedMarker.icon.size.height + offset/2 + (infoWindowHeight - offset/2)/2;
        self.actionOverlayCalloutView.center = point;
        
    } else {
        [self.actionOverlayCalloutView removeFromSuperview];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.actionOverlayCalloutView removeFromSuperview];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    if(currentMode == MapModeFollowedLocations || !userMovedMap) // disable pagination while displaying followed locations
        return;
    [self refreshMapData];
    self.detailsViewBottomConstraint.constant = - viewDetailsContainer.frame.size.height;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
    detailViewStatus = detailsViewStatusClosed;
    userMovedMap = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"mapView.selectedMarker"]) {
        if (!self.googleMapView.selectedMarker) {
            [self.actionOverlayCalloutView removeFromSuperview];
        }
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        selectedLocation = (Location*) marker.userData;
        listOfEventsinSelectedLocation = selectedLocation.events;
        if([listOfEventsinSelectedLocation count] > 0)
            [self onTimelinesListRecieved];
        //[self loadLocationTimelinesWithPage:0];
        //loaderView.hidden = NO;
    });
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didCloseInfoWindowOfMarker:(GMSMarker *)marker{
    selectedLocation = nil;
    listOfEventsinSelectedLocation = nil;
    [self closeDetailsView];
    [self.actionOverlayCalloutView removeFromSuperview];
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
    //    if (indexPath.row == [listOfLocations count])
    //        return CELL_LOAD_MORE_HEIGHT;
    //    else
    // normal cell
    return CELL_LOCATION_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // add cell for load more
    if(selectedLocation == nil)
        return 0;
    if (isMoreData)
        return [listOfEventsinSelectedLocation count] + 1;
    return [listOfEventsinSelectedLocation count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"eventListCell";
    static NSString *CellIdentifier2 = @"loadingMoreCell";
    
    // cell for loading more.
    if ((indexPath.row == [listOfEventsinSelectedLocation count]) && isMoreData)
    {
        UITableViewCell *loadMoreCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(tableView.frame.size.width/2 - 22, 0, 44, 44);
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
    // event list cell
    EventListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Event *eventObj = [listOfEventsinSelectedLocation objectAtIndex:indexPath.row];
    [cell populateCellWithEventContent:eventObj withFollow:YES];
    
    // follow button
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followEventAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // mention button
    cell.mentionButton.tag = indexPath.row;
    [cell.mentionButton addTarget:self action:@selector(mentionOnEventAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // play event button
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(playEventAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

// Will display cell at index
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // load more data
    if ((indexPath.row == [listOfEventsinSelectedLocation count]) && isMoreData)
    {
        // loading process
        if (!loadingInProgress)
            [self loadLocationTimelinesWithPage:currentPage + 1];
    }
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // load more cell
    if ((indexPath.row == [listOfEventsinSelectedLocation count]) && isMoreData)
        return;
    selectedEvent = [listOfEventsinSelectedLocation objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"mapTimelinesCollectionSegue" sender:self];
    // deselect row for next touch
    [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
    // hide details vew
    [self closeDetailsView];
    detailViewStatus = detailsViewStatusClosed;
}

#pragma mark -
#pragma mark Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"mapTimelineSegue"]){
        if(tempActiveEventForAction){ // play event timeline
            // pass the active user to profile page
            TimelineController *timelineController = segue.destinationViewController;
            [timelineController setTimelineObject:selectedTimeline withLocation:nil orEvent:tempActiveEventForAction];
            tempActiveEventForAction = nil;
        }else{ // play location timeline
            // pass the active user to profile page
            TimelineController *timelineController = segue.destinationViewController;
            [timelineController setTimelineObject:selectedTimeline withLocation:selectedLocation orEvent:nil];
        }
    }else if ([[segue identifier] isEqualToString:@"mapTimelinesCollectionSegue"]){
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        TimelinesCollectionController *timelinesController = (TimelinesCollectionController*)[navController viewControllers][0];
        if(selectedEvent)
            [timelinesController setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:selectedEvent];
        else
            [timelinesController setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
        selectedEvent = nil;
    }else if([[segue identifier] isEqualToString:@"mapAddMentionSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        AddMentionController *addMentionController = (AddMentionController*)[navController viewControllers][0];
        [addMentionController setMentionListType:kTimelineTypeMention];
        [addMentionController setMentionType:kEventMentionToMap];
        addMentionController.enableGroups = YES;
    }else if([[segue identifier] isEqualToString:@"mapWeezCollectionSegue"])
    {
        UINavigationController *navController = [segue destinationViewController];
        WeezCollectionController *controller = (WeezCollectionController*)[navController viewControllers][0];
        [controller loadViewWithData:listOfLocations type:COLLECTION_TYPE_LOACTIONS];
    }
}

- (IBAction)trendingAction:(id)sender{
    currentMode = MapModeTrending;
    [trendingLocationsButton setSelected:YES];
    [followedLocationsButton setSelected:NO];
    [self refreshMapData];
    //hide right bar button
    [self.navigationItem.rightBarButtonItem.customView setHidden:YES];
}

- (IBAction)followedAction:(id)sender{
    currentMode = MapModeFollowedLocations;
    [trendingLocationsButton setSelected:NO];
    [followedLocationsButton setSelected:YES];
    [self loadFollowedLocations];
    //show right bar button
    [self.navigationItem.rightBarButtonItem.customView setHidden:NO];
}

- (IBAction)toggleMapViewtypeAction:(id)sender{
    if(googleMapView.mapType == kGMSTypeSatellite){
        googleMapView.mapType = kGMSTypeNormal;
        [mapViewTypeToggleButton setImage:[UIImage imageNamed:@"mapSatBtn"] forState:UIControlStateNormal];
    }else{
        googleMapView.mapType = kGMSTypeSatellite;
        [mapViewTypeToggleButton setImage:[UIImage imageNamed:@"mapRoutBtn"] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark location actions
- (IBAction)followAction:(id)sender{
    UIButton *followButton = sender;
    [followButton setEnabled:NO];
    [[ConnectionManager sharedManager].userObject followLocation:selectedLocation.objectId];
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
         [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateNormal];
         [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateHighlighted];
         [followButton setImage:[UIImage imageNamed:@"locationFollowIcon"] forState:UIControlStateDisabled];
         if ([selectedLocation isFollowing])
         {
             [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateNormal];
             [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateHighlighted];
             [followButton setImage:[UIImage imageNamed:@"locationFollowIconActive"] forState:UIControlStateDisabled];
         }
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              followButton.alpha = 1.0;
              followButton.transform = CGAffineTransformScale(followButton.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {}];
     }];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followLocation:selectedLocation.objectId success:^(void)
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
         [[ConnectionManager sharedManager] getCurrentUser:^{
             [followButton setEnabled:YES];
         } failure:^(NSError *error) {
             [followButton setEnabled:YES];
         }];
     }
                                              failure:^(NSError * error)
     {
         [followButton setEnabled:YES];
     }];
}

- (IBAction)locationInfoAction:(id)sender{
    NSLog(@"info");
    [self performSegueWithIdentifier:@"mapTimelinesCollectionSegue" sender:self];
    
}

/// loads the location Timelines and once the data recieved will
/// launche the timelineController
- (IBAction)playLocationAction:(id)sender{
    if(selectedLocation == nil)
        return;
    
    loaderView.hidden = NO;
    NSString *lasUserId = @"";
    
    // get products list
    [[ConnectionManager sharedManager] getLocationTimelines:0 LocationId:selectedLocation.objectId lastId:lasUserId success:^(NSString *locationId, BOOL withPages, NSMutableArray* friends, NSMutableArray *newTimelines){
        
        [loaderView setHidden:YES];
        
        // if user diselected the location or selected a different location while we were tring to get the data
        if(selectedLocation == nil || ![selectedLocation.objectId isEqualToString:locationId]){
            return ;
        }
        
        // play the first timeline in location
        selectedTimeline = [newTimelines firstObject];
        [self performSegueWithIdentifier:@"mapTimelineSegue" sender:self];
        
    } failure:^(NSError *error){
        // end refreshing
        [loaderView setHidden:YES];
        // alert user for no internet
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

#pragma mark -
#pragma mark event actions
// Follow event
- (void)followEventAction:(UIButton*)sender
{
    [sender setEnabled:NO];
    int rowIndex = (int)sender.tag;
    Event *event = [listOfEventsinSelectedLocation objectAtIndex:rowIndex];
    [[ConnectionManager sharedManager].userObject followEvent:event.objectId];
    // animate the pressed voted image
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         sender.alpha = 0.0;
         sender.transform = CGAffineTransformScale(sender.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         // follow/unfollow this user
         [sender setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
         [sender setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
         if ([event isFollowing])
         {
             [sender setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
             [sender setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
         }
         [UIView animateWithDuration:0.1 delay:0.0 options: UIViewAnimationOptionTransitionCrossDissolve animations:^
          {
              sender.alpha = 1.0;
              sender.transform = CGAffineTransformScale(sender.transform, 2.0, 2.0);
          }
                          completion:^(BOOL finished)
          {
              [sender setEnabled:YES];
          }];
     }];
    // follow/unfollow user
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
             [self.usersTableView reloadData];
             [sender setEnabled:YES];
         } failure:^(NSError *error) {
             [sender setEnabled:YES];
         }];
     }
                                              failure:^(NSError * error)
     {
         [sender setEnabled:YES];
         [self.usersTableView reloadData];
     }];
}

-(void) mentionOnEventAction:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    tempActiveEventForAction = [listOfEventsinSelectedLocation objectAtIndex:rowIndex];
    [self performSegueWithIdentifier:@"mapAddMentionSegue" sender:self];
}

- (void)mentionToEvent:(NSMutableArray *) recepients{
    
    [[ConnectionManager sharedManager] mentionToEvent:tempActiveEventForAction recepients:recepients success:^()
     {
         // end refreshing
         [loaderView setHidden:YES];
         [[AppManager sharedManager] showNotification:@"TIMELINES_COLLECTION_MENTION_SUCCESS"  withType:kNotificationTypeSuccess];
         tempActiveEventForAction = nil;
     }
                                              failure:^(NSError *error)
     {
         // end refreshing
         [loaderView setHidden:YES];
         [[AppManager sharedManager] showNotification:@"TIMELINES_COLLECTION_MENTION_FAILED" withType:kNotificationTypeFailed];
         tempActiveEventForAction = nil;
     }];
}

- (IBAction)unwindMapEventMentionsSegue:(UIStoryboardSegue*)segue{
    
    AddMentionController *detailsController = (AddMentionController*)segue.sourceViewController;
    NSMutableArray *mentionList = [detailsController getAllMentionedUsersList];
    
    if ([mentionList count] > 0)
    {
        [self mentionToEvent:mentionList];
    }
}

-(void) playEventAction:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    tempActiveEventForAction = [listOfEventsinSelectedLocation objectAtIndex:rowIndex];
    
    loaderView.hidden = NO;
    NSString *lasUserId = @"";
    
    // get products list
    [[ConnectionManager sharedManager] getEventTimelines:0 eventId:tempActiveEventForAction.objectId lastId:lasUserId success:^(NSString *eventId, BOOL withPages, NSMutableArray *newFriends, NSMutableArray *newTimelines){
        
        [loaderView setHidden:YES];
        // if user diselected the location or selected a different location while we were tring to get the data
        if(tempActiveEventForAction == nil || ![tempActiveEventForAction.objectId isEqualToString:eventId]){
            return ;
        }
        // play the first timeline in location
        selectedTimeline = [newTimelines firstObject];
        [self performSegueWithIdentifier:@"mapTimelineSegue" sender:self];
    } failure:^(NSError *error){
        // end refreshing
        [loaderView setHidden:YES];
        // alert user for no internet
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}


#pragma mark -
#pragma mark Loading
// Start loader
- (void)startIndicator{
    [loaderView setHidden:NO];
}

// Stop indicator
- (void)stopIndicator{
    [loaderView setHidden:YES];
}

-(void) openDetailsView{
    //details view expands to match height of available items
    // if height if of available items exeeds details view height then only show as muct has the details view fits
    int newConstraintConstant = - (viewDetailsContainer.frame.size.height - (CELL_LOCATION_HEIGHT *[listOfEventsinSelectedLocation count]));
    if( newConstraintConstant > 0 )
        newConstraintConstant = 0;
    self.detailsViewBottomConstraint.constant = newConstraintConstant;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
}

-(void) closeDetailsView{
    self.detailsViewBottomConstraint.constant = - viewDetailsContainer.frame.size.height;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
}

@end
