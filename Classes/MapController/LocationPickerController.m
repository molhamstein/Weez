//
//  MapController.m
//  Weez
//
//  Created by Molham on 6/14/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "LocationPickerController.h"
#import "Location.h"
#import "AppManager.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "TimelineController.h"
#import "LocatoinAnnotation.h"
#import "TimelinesCollectionController.h"
#import "LocationListCell.h"
#import "TagCollectionViewCell.h"
#import "TimelineHeaderCell.h"
#import "CustomIOSAlertView.h"
#import "ChatController.h"
#import "PreviewMediaController.h"

@import GooglePlaces;

typedef enum{
    detailsViewStatusExpanded = 0,
    detailsViewStatusMinimized = 1,
    detailsViewStatusClosed = 2
} LocationsListStatus;

#define unwindToChat 3
#define unwindToPreview 4

@interface LocationPickerController ()
{
    LocationsListStatus locationsListStatus;
    BOOL loadingInProgress;
    BOOL userMovedMap;
    
    // configs
    BOOL limitToOnlyNearLocations;
    BOOL enableTags;
    BOOL allowSelectingCoordinates;
    int unwindToType;
}
@end


@implementation LocationPickerController
{


}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // configure view
    [self configView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (animated){
        GMSCameraPosition *camera;
        if(CLLocationCoordinate2DIsValid(_initialMapPosition))
            camera = [GMSCameraPosition cameraWithTarget:_initialMapPosition zoom:13];
        else
            camera = [GMSCameraPosition cameraWithTarget:[AppManager sharedManager].currenttUserLocation.coordinate zoom:13];
        
        _googleMapView.myLocationEnabled = YES;
        _googleMapView.settings.myLocationButton = YES;
        [_googleMapView setCamera:camera];
        [self reloadLocationsData];
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
    
    // right bar button
    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 44);
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_PICKER_OK"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = barButton2;
    
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"PICK_LOCATION_TITLE"];
    
    _lblTagsTitle.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    _lblTagsTitle.text = [[AppManager sharedManager] getLocalizedString:@"PICK_LOCATION_TAGS_TITLE"];
    
    if(!_listOfTags)
        _listOfTags = [[NSMutableArray alloc] init];
    _customSelectedCoord = kCLLocationCoordinate2DInvalid;
    
    //loader
    _loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    
    // init map
    _googleMapView.delegate = self;
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
    if(limitToOnlyNearLocations){
        _googleMapView.settings.zoomGestures = NO;
        _googleMapView.settings.tiltGestures = NO;
        _googleMapView.settings.rotateGestures = NO;
        _googleMapView.settings.scrollGestures = NO;
    }
    
    // init tableView
    self.detailsViewBottomConstraint.constant = - _viewDetailsContainer.frame.size.height;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [self.viewDetailsContainer layoutIfNeeded];
    locationsListStatus = detailsViewStatusClosed;
    _locationsTableView.bounces = NO;
    
    [[AppManager sharedManager] addViewDropShadow:_viewDetailsContainer withOpacity:0.2];
    
    if(!enableTags){
        _tagsViewHeightConstraint.constant = 0;
        [_tagsContainer setNeedsUpdateConstraints];
        [self.viewDetailsContainer layoutIfNeeded];
    }
    
    UIPanGestureRecognizer *gestRecTableSwipe = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeTable:)];
    [gestRecTableSwipe setDelegate:self];
    gestRecTableSwipe.cancelsTouchesInView = NO;
    [_locationsTableView addGestureRecognizer:gestRecTableSwipe];
}

// Cancel action
- (void)doneAction{
    // dismiss view
    if(unwindToType == unwindToChat)
        [self performSegueWithIdentifier:@"unwindPickLocationForChat" sender:self];
    else
        [self performSegueWithIdentifier:@"unwindLocationSegue" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Cancel action
- (void)cancelAction{
    _selectedLocation = nil;
    _listOfTags = nil;
    _selectedEvent = nil;
    _customSelectedCoord = kCLLocationCoordinate2DInvalid;
    
    // dismiss view
    if(unwindToType == unwindToChat)
        [self performSegueWithIdentifier:@"unwindPickLocationForChat" sender:self];
    else
        [self performSegueWithIdentifier:@"unwindLocationSegue" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareControllerWithlimitToOnlyNearLocations:(BOOL)limitToNearLocations initialMapPos:(CLLocationCoordinate2D)initPos enableTags:(BOOL)tagsEnable allowSelectingCoordinates:(BOOL)allowCoordinates parentViewController:(UIViewController*)parent{
    
    limitToOnlyNearLocations = limitToNearLocations;
    _initialMapPosition = initPos;
    enableTags = tagsEnable;
    allowSelectingCoordinates = allowCoordinates;
    
    if([parent isMemberOfClass:[ChatController class]])
        unwindToType = unwindToChat;
    else
        unwindToType = unwindToPreview;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didMoveMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        userMovedMap = YES;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if(allowSelectingCoordinates){
        _customSelectedCoord = coordinate;
        _selectedLocation = nil;
        _selectedEvent = nil;
        [self reloadMapAnnotations];
        [_locationsTableView reloadData];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//    });
    if(marker.userData){
        _customSelectedCoord = kCLLocationCoordinate2DInvalid;
        if([marker.userData isMemberOfClass:[Location class]])
            _selectedLocation = (Location*) marker.userData;
        else
            _selectedEvent = (Event*) marker.userData;
    
        [self reloadMapAnnotations];
        [_locationsTableView reloadData];
    }
    return NO;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    if(!userMovedMap)
        return;
    
    [self reloadLocationsData];
//    self.detailsViewBottomConstraint.constant = - _viewDetailsContainer.frame.size.height;
//    [self.viewDetailsContainer setNeedsUpdateConstraints];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.viewDetailsContainer layoutIfNeeded];
//    }];
//    locationsListStatus = detailsViewStatusClosed;
    userMovedMap = NO;
}

- (void)didSwipeTable:(UIPanGestureRecognizer*)gestureRecognizer {
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        //if we are at the first view in the tableview and the user swiped up then expand the details view
        if((locationsListStatus == detailsViewStatusMinimized || locationsListStatus == detailsViewStatusClosed)
           && movement.y < -50){
            
            [self openDetailsView];
            _locationsTableView.scrollEnabled = YES;
            locationsListStatus = detailsViewStatusExpanded;
        }else if(locationsListStatus == detailsViewStatusExpanded && movement.y > 130){
            
            self.detailsViewBottomConstraint.constant = - (_viewDetailsContainer.frame.size.height - CELL_LOCATION_HEIGHT);
            [self.viewDetailsContainer setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2 animations:^{
                [self.viewDetailsContainer layoutIfNeeded];
            }];
            //[usersTableView scrollsToTop];
            _locationsTableView.scrollEnabled = NO;
            locationsListStatus = detailsViewStatusClosed;
        }
    }
}

#pragma mark -
#pragma mark Data
- (void)reloadLocationsData{
    
    GMSVisibleRegion vr = _googleMapView.projection.visibleRegion;
    double centerLat = _googleMapView.camera.target.latitude;
    double centerLon = _googleMapView.camera.target.longitude;
    
    //double centerLon = vr.farLeft.longitude + ( vr.farRight.longitude - vr.farLeft.longitude)/2;
    CLLocation *centerLoc = [[CLLocation alloc]initWithLatitude:centerLat longitude:centerLon];
    CLLocation *farLeftLoc = [[CLLocation alloc]initWithLatitude:vr.farLeft.latitude longitude:vr.farLeft.longitude];
    CLLocationDistance distance = [centerLoc distanceFromLocation:farLeftLoc];
    [self loadLocationsDataWithLocationsLat:centerLat andLong:centerLon andRadius:distance];
    
}

- (void)loadLocationsDataWithLocationsLat:(float)lat andLong:(float) longitude andRadius:(double)radius{
    if(loadingInProgress)
        return;
    [self startIndicator];
    loadingInProgress = YES;
    // request data from the api
    [[ConnectionManager sharedManager] getLocationsAndEventsListNearLat:lat andLong:longitude Success:^(NSMutableArray *locationsList, NSMutableArray *eventsList, NSMutableArray *placesList)
     {
         listOfLocationsAndEvents = [[NSMutableArray alloc] init];
         [listOfLocationsAndEvents addObjectsFromArray:locationsList];
         [listOfLocationsAndEvents addObjectsFromArray:eventsList];
         listOfPlaces = placesList;
         
         [self stopIndicator];
         loadingInProgress = NO;
         [self onLocationsDataRecieved];
     }
                                                failure:^(NSError *error)
     {
         [self stopIndicator];
         loadingInProgress = NO;
     }];

}


- (void) onLocationsDataRecieved{
    [_locationsTableView reloadData];
    [_locationsTableView setContentOffset:CGPointZero animated:YES];
    
    _locationsTableView.scrollEnabled = YES;
    
    // make sure to open the locations list if its closed
    // this list will be closed the first time we open the sceen till we get some data to show
    if(locationsListStatus == detailsViewStatusClosed){
        [self openDetailsView];
    }
    
    [self reloadMapAnnotations];
}

// Reload map annotations
- (void)reloadMapAnnotations{
    
    [_googleMapView clear];
    
    // weez locations
    for (int i = 0; i < [listOfLocationsAndEvents count]; i++){
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
        marker.snippet = nil;
        marker.icon = [UIImage imageNamed:@"mapAnnotation"];
        marker.map = _googleMapView;
        
        if([[listOfLocationsAndEvents objectAtIndex:i] isMemberOfClass:[Location class]]){
            Location *providerObj = [listOfLocationsAndEvents objectAtIndex:i];
            marker.position = CLLocationCoordinate2DMake(providerObj.latitude, providerObj.longitude);
            marker.title = providerObj.name;
            marker.userData = providerObj;
        }else{ // it's an event
            Event *providerObj = [listOfLocationsAndEvents objectAtIndex:i];
            marker.position = CLLocationCoordinate2DMake(providerObj.location.latitude, providerObj.location.longitude);
            marker.title = providerObj.name;
            marker.userData = providerObj;
        }
    }
    
    // add marker for location selected by user by tapping
    if(CLLocationCoordinate2DIsValid(_customSelectedCoord)){
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(_customSelectedCoord.latitude, _customSelectedCoord.longitude);
        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
        marker.snippet = nil;
        marker.icon = [UIImage imageNamed:@"mapAnnotationSelected"];
        //marker.userData = providerObj;
        marker.map = _googleMapView;
    }
    
//    // google places
//    for (int i = 0; i < [listOfPlaces count]; i++){
//        Location *providerObj = [listOfPlaces objectAtIndex:i];
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.position = CLLocationCoordinate2DMake(providerObj.latitude, providerObj.longitude);
//        marker.title = providerObj.name;
//        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
//        marker.snippet = nil;
//        marker.icon = [UIImage imageNamed:@"mapAnnotation"];
//        marker.userData = providerObj;
//        marker.map = _googleMapView;
//    }
}

-(void) removeTag:(id)sender{
    UIButton *btnRemove = (UIButton*) sender;
    [_listOfTags removeObjectAtIndex:btnRemove.tag];
    
    [_tagsCollectionView reloadData];
}


#pragma mark -
#pragma mark - UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// Number of items
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    if(_listOfTags != nil)
        return [_listOfTags count] +1;
    return 1;
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier1 = @"tagCell";
    static NSString *CellIdentifier2 = @"addTagCell";
    
    
    // btn add new tag
    if([indexPath row] >= [_listOfTags count]){
        //show more cell
        UICollectionViewCell * showMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier2 forIndexPath:indexPath];
        return showMoreCell;
    // tag cell
    }else{
        TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        NSString *tag = _listOfTags[indexPath.row];
        [cell populateCellWithContent:tag];
        cell.deleteButton.tag = indexPath.item;
        [cell.deleteButton addTarget:self action:@selector(removeTag:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

// Select tag item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // click on the add tag button
    if([indexPath row] >= [_listOfTags count]){
        [self showAddTagDialog];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if([indexPath row] >= [_listOfTags count]){
        return CGSizeMake(30,30);
    }else{
        NSString *tag = [_listOfTags objectAtIndex:indexPath.item];
        CGRect stringRect = [tag boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
                                                options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                             attributes:@{ NSFontAttributeName : [[AppManager sharedManager] getFontType:kAppFontDescription] }
                                                context:nil];
        stringRect.size.width += 20; // padding
        stringRect.size.height = 30;
        return stringRect.size;
    }
}


#pragma mark -
#pragma mark Tableview data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(listOfLocationsAndEvents && listOfPlaces && [listOfPlaces count]>0 && [listOfLocationsAndEvents count]>0)
        return 2;
    else
        return 1;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TimelineHeaderCell *header = (TimelineHeaderCell *)[tableView dequeueReusableCellWithIdentifier:@"timelineHeaderCell"];
    NSString *title;
    if(section == 0)
        title = [[AppManager sharedManager]getLocalizedString:@"PICK_LOCATION_WEEZ_LOCATIONS_TITLE"];
    else
        title = [[AppManager sharedManager]getLocalizedString:@"PICK_LOCATION_OTHER_LOCATIONS_TITLE"];
    
    [header setTitle:title];
    return header;
}

// Footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_LOCATION_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        if(listOfLocationsAndEvents)
            return [listOfLocationsAndEvents count];
        return 0;
    }else{
        if(listOfPlaces)
            return  [listOfPlaces count];
        return 0;
    }
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier1 = @"locationListCell";
    if(indexPath.section == 0){
        // location list cell
        LocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        if([[listOfLocationsAndEvents objectAtIndex:indexPath.row] isMemberOfClass:[Location class]]){
            Location *locationObj = [listOfLocationsAndEvents objectAtIndex:indexPath.row];
            [cell populateCellWithContent:locationObj withSelected:[_selectedLocation.objectId isEqual:locationObj.objectId]];
        }else{ //event
            Event *locationObj = [listOfLocationsAndEvents objectAtIndex:indexPath.row];
            [cell populateCellWithEventContent:locationObj isSelected:[_selectedEvent.objectId isEqual:locationObj.objectId]];
        }
        return cell;
    }else{
        // location list cell
        LocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Location *locationObj = [listOfPlaces objectAtIndex:indexPath.row];
        [cell populateCellWithContent:locationObj withSelected:[_selectedLocation.objectId isEqual:locationObj.objectId]];
        return  cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    [UIView performWithoutAnimation:^{
        [view layoutIfNeeded];
    }];
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // invalidate any previously selected coordinate
    _customSelectedCoord = kCLLocationCoordinate2DInvalid;
    
    if(indexPath.section == 0){ // locations and events section
        if([[listOfLocationsAndEvents objectAtIndex:indexPath.item] isMemberOfClass:[Location class]]){
            Location *newSelectedLocation = [listOfLocationsAndEvents objectAtIndex:indexPath.row];
            // select/ deselect location
            if([newSelectedLocation.objectId isEqualToString:_selectedLocation.objectId])
                _selectedLocation = nil;
            else
                _selectedLocation = newSelectedLocation;
            _selectedEvent = nil;
        }else{
            Event *newSelectedLocation = [listOfLocationsAndEvents objectAtIndex:indexPath.row];
            // select/ deselect location
            if([newSelectedLocation.objectId isEqualToString:_selectedEvent.objectId])
                _selectedEvent = nil;
            else
                _selectedEvent = newSelectedLocation;
            _selectedLocation = nil;
        }
    }else{ // google places section
        Location *newSelectedLocation = [listOfPlaces objectAtIndex:indexPath.row];
        // select/ deselect location
        if([newSelectedLocation.objectId isEqualToString:_selectedLocation.objectId])
            _selectedLocation = nil;
        else
            _selectedLocation = newSelectedLocation;
        _selectedEvent = nil;
    }
    [self reloadMapAnnotations];
    [_locationsTableView reloadData];
    // deselect row for next touch
    [_locationsTableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark -
#pragma mark Control Views
// Start loader
- (void)startIndicator{
    [self.loaderView setHidden:NO];
}

// Stop indicator
- (void)stopIndicator{
    [self.loaderView setHidden:YES];
}

-(void) openDetailsView{
    //details view expands to match height of available items
    // if height if of available items exeeds details view height then only show as muct has the details view fits
    int newConstraintConstant = - (_viewDetailsContainer.frame.size.height - (CELL_LOCATION_HEIGHT *([listOfLocationsAndEvents count] + [listOfPlaces count]))) +30; // -30 for header height
    if( newConstraintConstant > 0 )
        newConstraintConstant = 0;
    self.detailsViewBottomConstraint.constant = newConstraintConstant;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
}

-(void) closeDetailsView{
    self.detailsViewBottomConstraint.constant = - _viewDetailsContainer.frame.size.height;
    [self.viewDetailsContainer setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewDetailsContainer layoutIfNeeded];
    }];
}

- (void)showAddTagDialog{
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_CANCEL"], [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_OK"], nil]];
    UIView *alertContetn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 90)];
    // title
    UILabel *alertTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 60)];
    alertTitle.font = [[AppManager sharedManager] getFontType:kAppFontTitle];
    alertTitle.numberOfLines = 3;
    alertTitle.textAlignment= NSTextAlignmentCenter;
    alertTitle.text = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_TITLE"];
    
    //tag icon
    UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 30, 30)];
    tagImageView.contentMode = UIViewContentModeCenter;
    tagImageView.layer.masksToBounds = YES;
    tagImageView.image = [UIImage imageNamed:@"tagIcon"];
    
    UITextField *alertInputField = [[UITextField alloc] initWithFrame:CGRectMake(40, 50, 220, 30)];
    alertInputField.placeholder = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_PLACEHOLDER"];
    alertInputField.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    [alertInputField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    
    [alertContetn addSubview:tagImageView];
    [alertContetn addSubview:alertTitle];
    [alertContetn addSubview:alertInputField];
    [alertView setContainerView: alertContetn];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        if (buttonIndex == 1){
            if(alertInputField.text && ![alertInputField.text isEqualToString:@""]){
                [_listOfTags addObject:alertInputField.text];
                [_tagsCollectionView reloadData];
            }
        }
        [alertView close];
    }];
    [alertView show];
    // after show set the parentView to prevent orientaton change of alertview
    alertView.parentView = self.view;
    [alertInputField becomeFirstResponder];
}

-(void) textFieldDidChange:(UITextField*) textField{
    NSString *originalString = textField.text;
    NSString *newString = [originalString stringByReplacingOccurrencesOfString:@" " withString:@"_" ];
    
    // remove special characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890ضصثقفغعهخحجدذشسيبلاتنمكطئءؤرلاىةوزظْأإف"] invertedSet];
    NSString *resultString = [[newString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    resultString = [resultString lowercaseString];
    //NSLog (@"Result: %@", resultString);
    
    textField.text = resultString;
}


@end
