//
//  MessagesListController.m
//  Weez
//
//  Created by Dania on 11/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "MessagesListController.h"
#import "AppManager.h"
#import "TimelineChatListCell.h"
#import "ProfileController.h"
#import "ConnectionManager.h"
#import "ReportType.h"
#import "UserRelatedLocationsController.h"
#import "ChatController.h"

@implementation MessagesListController


@synthesize usersTableView;
@synthesize searchView;
@synthesize searchTextField;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // hide view
    [noResultView setHidden:YES];
    [backgroundButton setHidden:YES];
    [usersTableView setHidden:YES];
    selectedTimeline = [[Timeline alloc] init];
    // configure controls
    [self configureViewControls];
    loadingInprogress = NO;
    [self loadData];
}


// Configure view controls
- (void)configureViewControls
{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 12, 12);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navCloseIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.rightBarButtonItem = barButton;
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // refresh control
    tableRefreshControl = [[UIRefreshControl alloc] init];
    [tableRefreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [usersTableView addSubview:tableRefreshControl];
    // set fonts
    [searchTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // messages list
        // set text
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"HOME_SECTION_MESSAGES"];
        searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"MESSAGES_SEARCH_PLACEHOLDER"];
        noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"ADD_FRIEND_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:searchView];
    [[AppManager sharedManager] flipViewDirection:usersTableView];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshTable
{
    if(!loadingInprogress)
        [self loadData];
}

// Load list of messages
- (void)loadData
{
    loadingInprogress = YES;
    // start animation
    if([listOfMessages count] == 0)
    {
        [usersTableView setHidden:YES];
        [noResultView setHidden:YES];
        [loaderView setHidden:NO];
    }
    [searchTextField setEnabled:NO];
    // empty lists
    listOfMessages = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] messagesList]];
    filteredList = listOfMessages;
    // get messages list
    // get chat list
    [[ConnectionManager sharedManager] getchatList:0 success:^(BOOL withPages)
     {
         loadingInprogress = NO;
         // stop loader
         [loaderView setHidden:YES];
         [searchTextField setEnabled:YES];
         // end refreshing
         [tableRefreshControl endRefreshing];
         // fill in data
         listOfMessages = [[NSMutableArray alloc] initWithArray:[[ConnectionManager sharedManager] messagesList]];
         // refresh filtered list
         [self refreshFilteredList];
     }
                                           failure:^(NSError *error)
     {
         loadingInprogress = NO;
         // end refreshing
         [tableRefreshControl endRefreshing];
         // stop loader
         [loaderView setHidden:YES];
         // no result
         [noResultView setHidden:NO];
         [usersTableView setHidden:YES];
         // show notification error
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];     }];
   
}

// Refresh filtered users list
- (void)refreshFilteredList
{
    // set all friends in the filtered array
    filteredList = [[NSMutableArray alloc] initWithArray:listOfMessages];
    searchTextField.text = @"";
    [noResultView setHidden:YES];
    [usersTableView setHidden:NO];
    [usersTableView reloadData];
    // show empty view
    if ([listOfMessages count] == 0)
    {
        [noResultView setHidden:NO];
        [searchTextField setEnabled:NO];
        [usersTableView setHidden:YES];
    }
}

#pragma mark -
#pragma mark Actions
// Search for player
- (void)searchForPlayer
{
    // search for local friends
    [filteredList removeAllObjects];
    // check full messages list
    for (Timeline *objFriend in listOfMessages)
    {
        // display name or username
        if ([objFriend.username rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
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

// Follow user
-(IBAction)followActionUser:(NSString*)userId{
    [[ConnectionManager sharedManager].userObject followFriend:userId];
    // follow/unfollow user
    [[ConnectionManager sharedManager] followUser:userId success:^(void){
        // notify about timeline changes
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
    }
                                          failure:^(NSError * error)
     {
     }];
}

#pragma mark -
#pragma mark Actions Sheet


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
    if([timeline isFollowing])
        [btn2 setImage:[UIImage imageNamed:@"actionUserFollow"] forState:UIControlStateNormal];
    else
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

// Action sheet pressed button
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
     if(actionSheet.tag == kSheetUserActions){
        if (buttonIndex == 0){ // user related locations
            selectedTimelineToViewProfile = selectedTimeline;
            selectedTimeline = nil;
            [self performSegueWithIdentifier:@"messagesListUserRelatedLocationsSegue" sender:self];
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


#pragma mark -
#pragma mark SWTableViewCellDelegate
// Scrolling state
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath *indexPath = [usersTableView indexPathForCell:cell];
    UIButton *btn = [[cell rightUtilityButtons] objectAtIndex:index];
    NSInteger tag = btn.tag;
    //get selected timeline
    selectedTimeline = [filteredList objectAtIndex:indexPath.row];
    switch (tag) {
        case CELL_SWIPE_ACTION_TAG_CHAT:
            [self performSegueWithIdentifier:@"messagesListChatSegue" sender:self];
            break;
        case CELL_SWIPE_ACTION_TAG_MORE:
            [self showUserActionsSheetAction:selectedTimeline];
            break;
    }
    [cell hideUtilityButtonsAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
    return [filteredList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"timelineChatListCell";
    TimelineChatListCell * cell = (TimelineChatListCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Timeline *timelineObj = [filteredList objectAtIndex:indexPath.row];
    [cell populateCellWithContent:timelineObj];
    [cell initSwipeActions:self];
    // open profile button
    cell.profileButton.tag = indexPath.row;
    cell.profileButton.imageView.tag = indexPath.section;
    
    if(timelineObj.timelineType != kTimelineTypeGroup){
        [cell.profileButton addTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
        cell.profileButton.hidden = NO;
    }else{
        [cell.profileButton removeTarget:self action:@selector(profileActionWithUser:) forControlEvents:UIControlEventTouchUpInside];
        cell.profileButton.hidden = YES; // hide btn to enable cell click
    }
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedTimeline = [filteredList objectAtIndex:indexPath.row];
    if(selectedTimeline.canChat){
        [self performSegueWithIdentifier:@"messagesListChatSegue" sender:self];//TODO
    }else{
        selectedTimeline = nil;
    }

    
    // deselect row for next touch
    [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)profileActionWithUser:(UIButton*)sender{
    
    int rowIndex = (int)sender.tag;
    selectedTimeline = [listOfMessages objectAtIndex:rowIndex];
    [self performSegueWithIdentifier:@"messagesListProfileSegue" sender:self];//TODO
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


#pragma mark -
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
     if ([[segue identifier] isEqualToString:@"messagesListProfileSegue"]){
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        //show user profile after taping on push notification that's says someone follow you
       
            if(selectedTimelineToViewProfile == nil)
                [profileController setProfileWithUser:[ConnectionManager sharedManager].userObject];
            else{
                [profileController setProfileWithTimeline:selectedTimelineToViewProfile];
                selectedTimelineToViewProfile = nil;
            }
    }
    // go to chat from home page
    else if ([[segue identifier] isEqualToString:@"messagesListChatSegue"]){
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        //handle tapping on push notification that's says someone send you a message
            [chatController setTimeline:selectedTimeline];
            selectedTimeline = nil;
    }else if([segue.identifier isEqualToString:@"messagesListUserRelatedLocationsSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        UserRelatedLocationsController *locationsController = (UserRelatedLocationsController*)[navController viewControllers][0];
        [locationsController setUserId:selectedTimelineToViewProfile.userId];
        selectedTimelineToViewProfile = nil;
    }
}


@end
