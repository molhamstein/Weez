//
//  LocationListController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "LocationListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "LocationListCell.h"

@implementation LocationListController

@synthesize selectedLocation;
@synthesize locationsTableView;
@synthesize searchView;
@synthesize searchLabel;
@synthesize searchTextField;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;
@synthesize selectedEvent;
@synthesize googlePlacesPickedLocation;
@synthesize limitToCloseLocationsOnly;
@synthesize limitToDefinedPlacesOnly;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [backgroundButton setHidden:YES];
    [locationsTableView setHidden:YES];
    // configure controls
    [self configureViewControls];
    [self loadData];
}

// Configure view controls
- (void)configureViewControls
{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    // right button
    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 19, 19);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"navPickPlaceIcon"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(pickLocationFromMapAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = barButton2;
    
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // set fonts
    [searchLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [searchTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_LOCATIONS"];
    searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_DESC"];
    searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_PLACEHOLDER"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:searchView];
    [[AppManager sharedManager] flipViewDirection:locationsTableView];
}

// Cancel action
- (void)cancelAction
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // dismiss view
    [self performSegueWithIdentifier:@"unwindLocationSegue" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Set location id
- (void)setLocationId:(NSString*)locId withLocation:(Location*)location withEvent:(Event *)event
{
    locationId = locId;
    selectedLocation = location;
    selectedEvent = event;
    eventId = selectedEvent.objectId;
}

// Load list of following
- (void)loadData
{
    // start animation
    [locationsTableView setHidden:YES];
    [noResultView setHidden:YES];
    [loaderView setHidden:NO];
    [searchTextField setEnabled:NO];
    // empty lists
    fullLocationList = [[NSMutableArray alloc] init];
    filteredList = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getLocationsList:NO success:^(NSMutableArray *locationsList,  NSMutableArray *eventsList)
    {
        // stop loader
        [loaderView setHidden:YES];
        [searchTextField setEnabled:YES];
        // fill in data
        fullLocationList = [[NSMutableArray alloc] initWithArray:eventsList];
        [fullLocationList addObjectsFromArray:locationsList];
        // refresh filtered list
        [self refreshFilteredList];
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        // no result
        [noResultView setHidden:NO];
        [locationsTableView setHidden:YES];
        // show notification error
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Refresh filtered users list
- (void)refreshFilteredList
{
    // set all friends in the filtered array
    filteredList = [[NSMutableArray alloc] initWithArray:fullLocationList];
    searchTextField.text = @"";
    [noResultView setHidden:YES];
    [locationsTableView setHidden:NO];
    [locationsTableView reloadData];
    // show emptu view
    if ([fullLocationList count] == 0)
    {
        [noResultView setHidden:NO];
        [searchTextField setEnabled:NO];
        [locationsTableView setHidden:YES];
    }
}

// Search for location
- (void)searchForLocation
{
    // search for local location
    [filteredList removeAllObjects];
    // check full following list
    for(int i = 0 ; i< [fullLocationList count]; i++){
        if([[fullLocationList objectAtIndex:i] isKindOfClass:[Event class]]){
            Event *obj = [fullLocationList objectAtIndex:i];
            if ([obj.name rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [filteredList addObject:obj];
            }
        }else{ // location
            Location *obj = [fullLocationList objectAtIndex:i];
            if ([obj.name rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [filteredList addObject:obj];
            }
        }
    }
    [noResultView setHidden:NO];
    // result exist
    if ([filteredList count] > 0)
        [noResultView setHidden:YES];
    // reload table
    [locationsTableView reloadData];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // normal cell
    return CELL_LOCATION_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [filteredList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"locationListCell";
    // timeline list cell
    LocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    
    if([[filteredList objectAtIndex:indexPath.row] isKindOfClass:[Event class]]){
        Event *obj = [filteredList objectAtIndex:indexPath.row];
        BOOL isSelected = NO;
        if ([obj.objectId isEqualToString:eventId])
            isSelected = YES;
        [cell populateCellWithEventContent:obj];
    }else{
        Location *locationObj = [filteredList objectAtIndex:indexPath.row];
        BOOL isSelected = NO;
        if ([locationObj.objectId isEqualToString:locationId])
            isSelected = YES;
        [cell populateCellWithContent:locationObj withSelected:isSelected];
    }
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[filteredList objectAtIndex:indexPath.row] isKindOfClass:[Event class]]){
        locationId = @"";
        selectedLocation = nil;
        googlePlacesPickedLocation = nil;
        Event *eventObj = (Event*)[filteredList objectAtIndex:indexPath.row];
        // location selected
        if ([eventObj.objectId isEqualToString:eventId])
        {
            eventId = @"";
            selectedEvent = nil;
            [locationsTableView reloadData];
        }
        else// select new location
        {
            eventId = eventObj.objectId;
            [locationsTableView reloadData];
            // save selected location
            selectedEvent = eventObj;
            [self performSelector:@selector(backToPreview) withObject:nil afterDelay:0.0];
            // deselect row for next touch
            [locationsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }else{
        eventId = @"";
        selectedEvent = nil;
        googlePlacesPickedLocation = nil;
        Location *locationObj = (Location*)[filteredList objectAtIndex:indexPath.row];
        // location selected
        if ([locationObj.objectId isEqualToString:locationId])
        {
            locationId = @"";
            selectedLocation = nil;
            [locationsTableView reloadData];
        }
        else// select new location
        {
            locationId = locationObj.objectId;
            [locationsTableView reloadData];
            // save selected location
            selectedLocation = locationObj;
            [self performSelector:@selector(backToPreview) withObject:nil afterDelay:0.0];
            // deselect row for next touch
            [locationsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}

// Back to preview
- (void)backToPreview
{
    [self performSegueWithIdentifier:@"unwindLocationSegue" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark pick location
-(void) pickLocationFromMapAction
{
    // check loaction permissions
    locationManagr = [[CLLocationManager alloc] init];
    locationManagr.delegate = self;
    //locationManagr.distanceFilter = 300;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManagr requestWhenInUseAuthorization];
    }else{
        [locationManagr requestLocation];
    }
    
    CLLocationCoordinate2D center = [AppManager sharedManager].currenttUserLocation.coordinate;
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001,
                                                                  center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001,
                                                                  center.longitude - 0.001);
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            [[AppManager sharedManager] showNotification:@"LOCATIONS_LIST_GOOGLE_PLACES_FAIED" withType:kNotificationTypeFailed];
            return;
        }
        
        if (place != nil) {

            googlePlacesPickedLocation = [[Location alloc] init];
            googlePlacesPickedLocation.objectId = place.placeID;
            googlePlacesPickedLocation.name = place.name;
            googlePlacesPickedLocation.address = place.formattedAddress;
            googlePlacesPickedLocation.longitude = place.coordinate.longitude;
            googlePlacesPickedLocation.latitude = place.coordinate.latitude;
            NSArray* dic = place.addressComponents;
            if(!googlePlacesPickedLocation.address)
                googlePlacesPickedLocation.address = @"";
            for (int i = 0; i < [dic count]; i++) {
                GMSAddressComponent *addressComponent = [dic objectAtIndex:i];
                if([addressComponent.type isEqualToString:@"country"]){
                    googlePlacesPickedLocation.country = addressComponent.name;
                }else if([addressComponent.type isEqualToString:@"locality"]){
                    googlePlacesPickedLocation.city = addressComponent.name;
                }
                //NSLog(@"%@ , %@",addressComponent.type, addressComponent.name);
            }
            
            // mark the locations as undefined if its a coordinate place
            // detact coordinates in place name using regEx
            NSString *pattern = @"\\(([+-]?\\d+\\.?\\d+)\\s*,\\s*([+-]?\\d+\\.?\\d+)\\)";
            //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:nil error:&error];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
            if ([predicate evaluateWithObject: place.name]){
                googlePlacesPickedLocation.isUnDefinedPlace = YES;
            }else
                googlePlacesPickedLocation.isUnDefinedPlace = NO;
            
            // return result
            eventId = @"";
            locationId = @"";
            selectedLocation = nil;
            selectedEvent = nil;
            
            
            // dont allow coordinate based places, only defined places allowed
//            if(limitToDefinedPlacesOnly && googlePlacesPickedLocation.isUnDefinedPlace){
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
//                                                               message:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_NOT_DEF"]
//                                                              delegate:self
//                                                     cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_NOT_DEF_CNCL"]
//                                                     otherButtonTitles:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_NOT_DEF_OK"],nil];
//                [alert show];
//                return;
//                // if media recorrded for timeline, dont allow the user to use far locations from his currrent location
//            }else
            if(limitToCloseLocationsOnly && ![[AppManager sharedManager] isCloseToCurrentLocation:googlePlacesPickedLocation.latitude longitude:googlePlacesPickedLocation.longitude]){
                // check if locations is close enough to current location
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                               message:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_TOO_FAR"]
                                                              delegate:self
                                                     cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_TOO_FAR_CNCL"]
                                                     otherButtonTitles:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION_TOO_FAR_OK"],nil];
                [alert show];
                googlePlacesPickedLocation = nil;
                return;
            }
            
            // save selected location
            [self performSelector:@selector(backToPreview) withObject:nil afterDelay:0.0];
        } else { // No place selected
        }
    }];
}

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
    [AppManager sharedManager].currenttUserLocation = newLocation;
    [locationManagr stopUpdatingLocation];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1)
        [self pickLocationFromMapAction];
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // search for player
    if ([textField.text length] > 0)
        [self searchForLocation];
    else// refresh full list
        [self refreshFilteredList];
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

// Text field did change
- (IBAction)textFieldDidChange:(UITextField*)textField
{
    // searching
    if ([textField.text length] > 0)
        [self searchForLocation];
    else// refresh full list
        [self refreshFilteredList];
}

// End typing in text field
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [backgroundButton setHidden:YES];
    [AppManager sharedManager].activeField = nil;
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
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
