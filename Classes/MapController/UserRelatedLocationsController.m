//
//  UserRelatedLocationsController.m
//  Weez
//
//  Created by Molham on 25/09/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "UserRelatedLocationsController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "LocationListCell.h"
#import "LocationDetailsController.h"
#import "TimelinesCollectionController.h"

@implementation UserRelatedLocationsController

@synthesize locationsTableView;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize loaderView;
@synthesize selectedLocation;
@synthesize userId;
@synthesize selectedEvent;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [locationsTableView setHidden:YES];
    // configure controls
    [self configureViewControls];
    selectedLocation = nil;
}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"USER_RELATED_LOCATIONS"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"USER_LOCATIONS_LIST_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:locationsTableView];
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Load list of following
- (void)loadData
{
    // start animation
    [locationsTableView setHidden:YES];
    [noResultView setHidden:YES];
    [loaderView setHidden:NO];
    // empty lists
    listOfUserLocationsAndEvents = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getLocationsRelatedTo:userId success:^(NSMutableArray *locationsList, NSMutableArray *eventsList) {
        
        // stop loader
        [loaderView setHidden:YES];
        // fill in data
        listOfUserLocationsAndEvents = [[NSMutableArray alloc] initWithArray:locationsList];
        [listOfUserLocationsAndEvents addObjectsFromArray:eventsList];
        // refresh filtered list
        [noResultView setHidden:YES];
        [locationsTableView setHidden:NO];
        [locationsTableView reloadData];
        // show emptu view
        if ([listOfUserLocationsAndEvents count] == 0)
        {
            [noResultView setHidden:NO];
            [locationsTableView setHidden:YES];
        }
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
    return [listOfUserLocationsAndEvents count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"locationListCell";
    // timeline list cell
    LocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    if([[listOfUserLocationsAndEvents objectAtIndex:indexPath.item] isMemberOfClass:[Location class]]){
        Location *locationObj = [listOfUserLocationsAndEvents objectAtIndex:indexPath.row];
        [cell populateCellWithContent:locationObj];
    }else{
        Event *eventObj = [listOfUserLocationsAndEvents objectAtIndex:indexPath.row];
        [cell populateCellWithEventContent:eventObj];
    }
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLocation = nil;
    selectedEvent = nil;
    if([[listOfUserLocationsAndEvents objectAtIndex:indexPath.item] isMemberOfClass:[Location class]])
        selectedLocation = (Location*)[listOfUserLocationsAndEvents objectAtIndex:indexPath.row];
    else
        selectedEvent = (Event*)[listOfUserLocationsAndEvents objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"userRelatedLocationsTimelinesCollectionSegue" sender:self];
    // deselect row for next touch
    [locationsTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"userRelatedLocationsTimelinesCollectionSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = segue.destinationViewController;
        TimelinesCollectionController *locationDetailsController = navController.viewControllers[0];
        if(selectedLocation)
            [locationDetailsController setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
        else
            [locationDetailsController setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:selectedEvent];
    }
}

@end
