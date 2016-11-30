//
//  UserEventsController.m
//  Weez
//
//  Created by Molham on 09/01/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "UserEventsController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "LocationListCell.h"
#import "LocationDetailsController.h"
#import "EditEventController.h"

@implementation UserEventsController

@synthesize locationsTableView;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize loaderView;
@synthesize selectedLocation;

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
    
    // right button
    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 19, 19);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"navAddIcon"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(addLocationAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = barButton2;
    
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_EVENTS"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"EVENTS_LIST_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:locationsTableView];
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self.navigationController popViewControllerAnimated:YES];
}

// Load list of following
- (void)loadData
{
    // start animation
    [locationsTableView setHidden:YES];
    [noResultView setHidden:YES];
    [loaderView setHidden:NO];
    // empty lists
    eventsList = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getMyEventsList:^(NSMutableArray *locationsList)
     {
         // stop loader
         [loaderView setHidden:YES];
         // fill in data
         eventsList = [[NSMutableArray alloc] initWithArray:locationsList];
         // refresh filtered list
         [noResultView setHidden:YES];
         [locationsTableView setHidden:NO];
         [locationsTableView reloadData];
         // show emptu view
         if ([eventsList count] == 0)
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

// Add location
- (void)addLocationAction
{
    selectedLocation = nil;
    [self performSegueWithIdentifier:@"UserEventsEditEventSegue" sender:self];
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
    return [eventsList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"locationListCell";
    // timeline list cell
    LocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Event *locationObj = [eventsList objectAtIndex:indexPath.row];
    [cell populateCellWithEventContent:locationObj];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLocation = (Event *)[eventsList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"UserEventsEditEventSegue" sender:self];
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
    if ([[segue identifier] isEqualToString:@"UserEventsEditEventSegue"])
    {
        // pass the active user to profile page
        EditEventController *editEventController = segue.destinationViewController;
        [editEventController setEvent:selectedLocation];
    }
}

@end
