//
//  FollowingListController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "FollowingListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "FriendListCell.h"
#import "ProfileController.h"

@implementation FollowingListController

@synthesize usersTableView;
@synthesize searchView;
@synthesize searchLabel;
@synthesize searchTextField;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [backgroundButton setHidden:YES];
    [usersTableView setHidden:YES];
    selectedFriend = [[Friend alloc] init];
    // configure controls
    [self configureViewControls];
    [self loadData];
}

// Set follow type
- (void)setFollowType:(FollowType)type
{
    followType = type;
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
    [searchLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [searchTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // following list
    if (followType == kFollowTypeFollowing)
    {
        // set text
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_FOLLOWING"];
        searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"FOLLOWING_SEARCH_DESC"];
        searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"ADD_MENTION_PLACEHOLDER"];
        noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"FOLLOWING_NO_RESULT"];
    }
    else// followers list
    {
        // set text
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_FOLLOWERS"];
        searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"FOLLOWERS_SEARCH_DESC"];
        searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"ADD_MENTION_PLACEHOLDER"];
        noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"FOLLOWERS_NO_RESULT"];
    }
    // set view direction
    [[AppManager sharedManager] flipViewDirection:searchView];
    [[AppManager sharedManager] flipViewDirection:usersTableView];
}

-(void) updateFollowBtn :(UIButton*)followBtn
{
    int rowIndex = (int)followBtn.tag;
    Friend *friendObj = [filteredList objectAtIndex:rowIndex];
    FOLLOWING_STATE state = [friendObj getFollowingState];
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
    [followBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [followBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateDisabled];
    [followBtn setTitle:@"" forState:UIControlStateNormal];
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
    [self.navigationController popViewControllerAnimated:YES];
}

// Load list of following
- (void)loadData
{
    // start animation
    [usersTableView setHidden:YES];
    [noResultView setHidden:YES];
    [loaderView setHidden:NO];
    [searchTextField setEnabled:NO];
    // empty lists
    fullFollowingList = [[NSMutableArray alloc] init];
    filteredList = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getFollowingList:followType rankedBy:kTimelineTypeMention success:^(NSMutableArray *usersList)
    {
        // stop loader
        [loaderView setHidden:YES];
        [searchTextField setEnabled:YES];
        // fill in data
        fullFollowingList = [[NSMutableArray alloc] initWithArray:usersList];
        // refresh filtered list
        [self refreshFilteredList];
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        // no result
        [noResultView setHidden:NO];
        [usersTableView setHidden:YES];
        // show notification error
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Refresh filtered users list
- (void)refreshFilteredList
{
    // set all friends in the filtered array
    filteredList = [[NSMutableArray alloc] initWithArray:fullFollowingList];
    searchTextField.text = @"";
    [noResultView setHidden:YES];
    [usersTableView setHidden:NO];
    [usersTableView reloadData];
    // show empty view
    if ([fullFollowingList count] == 0)
    {
        [noResultView setHidden:NO];
        [searchTextField setEnabled:NO];
        [usersTableView setHidden:YES];
    }
}

// Search for player
- (void)searchForPlayer
{
    // search for local friends
    [filteredList removeAllObjects];
    // check full following list
    for (Friend *objFriend in fullFollowingList)
    {
        // display name or username
        if (([objFriend.displayName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
            || ([objFriend.username rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound))
        {
            [filteredList addObject:objFriend];
        }
    }
    [noResultView setHidden:NO];
    // result exist
    if ([filteredList count] > 0)
        [noResultView setHidden:YES];
    // reload table
    [usersTableView reloadData];
}

// Follow user
- (void)followUser:(UIButton*)sender
{
    [sender setEnabled:NO];
    int rowIndex = (int)sender.tag;
    Friend *friendObj = [filteredList objectAtIndex:rowIndex];
    [[ConnectionManager sharedManager].userObject followFriend:friendObj.objectId withPrivateProfile:friendObj.isPrivate];
    // animate the pressed voted image
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
    {
        sender.alpha = 0.0;
        sender.transform = CGAffineTransformScale(sender.transform, 0.5, 0.5);
    }
    completion:^(BOOL finished)
    {
        [self updateFollowBtn:sender];
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
    [[ConnectionManager sharedManager] followUser:friendObj.objectId success:^(void)
    {
        // notify about timeline changes
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
    }
    failure:^(NSError * error)
    {
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
    return [filteredList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"friendsListCell";
    // timeline list cell
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Friend *friendObj = [filteredList objectAtIndex:indexPath.row];
    [cell populateCellWithContent:friendObj];
    // follow button
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFriend = [filteredList objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"followingListProfileSegue" sender:self];
    // deselect row for next touch
    [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // search for player
    if ([textField.text length] > 0)
        [self searchForPlayer];
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
        [self searchForPlayer];
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"followingListProfileSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        [profileController setProfileWithFriend:selectedFriend];
    }
}

@end
