//
//  GroupListController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "GroupListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "MemberListCell.h"
#import "ChatController.h"

@implementation GroupListController

@synthesize groupsTableView;
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
    [groupsTableView setHidden:YES];
    selectedGroup = [[Group alloc] init];
    // empty lists
    listOfGroups = [[NSMutableArray alloc] init];
    // configure controls
    [self configureViewControls];
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
    // set fonts
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_GROUPS"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_NO_ITEMS"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:groupsTableView];
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
    if ([listOfGroups count] == 0)
    {
        [groupsTableView setHidden:YES];
        [noResultView setHidden:YES];
        [loaderView setHidden:NO];
    }
    // get following list
    [[ConnectionManager sharedManager] getGroupList:^(NSMutableArray *groupList)
    {
        // stop loader
        [loaderView setHidden:YES];
        [noResultView setHidden:YES];
        [groupsTableView setHidden:NO];
        // fill in data
        listOfGroups = [[NSMutableArray alloc] initWithArray:groupList];
        [groupsTableView reloadData];
        // show empty view
        if ([listOfGroups count] == 0)
        {
            [noResultView setHidden:NO];
            [groupsTableView setHidden:YES];
        }
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        // no result
        [noResultView setHidden:NO];
        [groupsTableView setHidden:YES];
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
    return CELL_USER_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [listOfGroups count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"memberListCell";
    // timeline list cell
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Group *groupObj = [listOfGroups objectAtIndex:indexPath.row];
    BOOL isAdmin = NO;
    if ([groupObj.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId])
        isAdmin = YES;
    [cell populateGroupWithContent:groupObj withAdmin:isAdmin];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedGroup = [listOfGroups objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"groupListChatSegue" sender:self];
    // deselect row for next touch
    [groupsTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"groupListChatSegue"])
    {
        // pass the active user to profile page
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        [chatController setGroup:selectedGroup withParent:nil];
    }
}

@end
