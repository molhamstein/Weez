//
//  MentionListController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "MentionListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "TimelineListCell.h"
#import "TimelineController.h"

@implementation MentionListController

@synthesize timelineTableView;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize loaderView;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [timelineTableView setHidden:YES];
    selectedTimeline = [[Timeline alloc] init];
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
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // set fonts
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_MENTIONS"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"HOME_NO_TIMELINES"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:timelineTableView];
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
    [timelineTableView setHidden:YES];
    [noResultView setHidden:YES];
    [loaderView setHidden:NO];
    // empty lists
    listOfTimelines = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getMentionList:^(NSMutableArray *mentionList)
    {
        // stop loader
        [loaderView setHidden:YES];
        [noResultView setHidden:YES];
        [timelineTableView setHidden:NO];
        // fill in data
        listOfTimelines = [[NSMutableArray alloc] initWithArray:mentionList];
        [timelineTableView reloadData];
        // show empty view
        if ([listOfTimelines count] == 0)
        {
            [noResultView setHidden:NO];
            [timelineTableView setHidden:YES];
        }
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        // no result
        [noResultView setHidden:NO];
        [timelineTableView setHidden:YES];
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
    return CELL_TIMELINE_LIST_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfTimelines count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"timelineListCell";
    // timeline list cell
    TimelineListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Timeline *timelineObj = [listOfTimelines objectAtIndex:indexPath.row];
    [cell populateCellWithContent:timelineObj];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedTimeline = [listOfTimelines objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"mentionListTimelineSegue" sender:self];
    // deselect row for next touch
    [timelineTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"mentionListTimelineSegue"])
    {
        // pass the active user to profile page
        TimelineController *timelineController = segue.destinationViewController;
        [timelineController setTimelineObject:selectedTimeline withLocation:nil orEvent:nil];
    }
}

@end
