//
//  AddMentionController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "AddMentionController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "FriendListCell.h"
#import "MemberListCell.h"
#import "Group.h"

@implementation AddMentionController

@synthesize mentionedList;
@synthesize usersTableView;
@synthesize searchView;
@synthesize searchLabel;
@synthesize searchTextField;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;
@synthesize mentionType;
@synthesize enableGroups;
@synthesize mentionedGroupsList;

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
    // configure controls
    [self configureViewControls];
    mentionedList = [[NSMutableArray alloc] init];
    mentionedGroupsList = [[NSMutableArray alloc] init];
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
    rightButton.frame = CGRectMake(0, 0, 60, 44);
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_PICKER_OK"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveMentionList) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
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
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_FOLLOWING"];
    searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"ADD_MENTION_DESC"];
    searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"ADD_MENTION_PLACEHOLDER"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"ADD_MENTION_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:searchView];
    [[AppManager sharedManager] flipViewDirection:usersTableView];
}

// Set list type
- (void)setMentionListType:(TimelineType)type
{
    listType = type;
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
    fullGroupsList = [[NSMutableArray alloc] init];
    filteredGroupsList = [[NSMutableArray alloc] init];
    
    // get following list
    [[ConnectionManager sharedManager] getFollowingList:kFollowTypeFollowing rankedBy:listType success:^(NSMutableArray *usersList)
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
    
    if(enableGroups){
        [[ConnectionManager sharedManager] getGroupList:^(NSMutableArray *groupList)
         {
             // stop loader
             [loaderView setHidden:YES];
             [searchTextField setEnabled:YES];
             // fill in data
             fullGroupsList = [[NSMutableArray alloc] initWithArray:groupList];
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
}

// Refresh filtered users list
- (void)refreshFilteredList
{
    // set all friends in the filtered array
    filteredList = [[NSMutableArray alloc] initWithArray:fullFollowingList];
    
    // groups list
    if(enableGroups){
        // set all groups in the filtered array
        filteredGroupsList = [[NSMutableArray alloc] initWithArray:fullGroupsList];
    }
    
    searchTextField.text = @"";
    [noResultView setHidden:YES];
    [usersTableView setHidden:NO];
    [usersTableView reloadData];
    // show empty view
    if(enableGroups)
    if ((!enableGroups&&([fullFollowingList count] == 0)) ||
        (enableGroups && ([fullFollowingList count] == 0) && ([fullGroupsList count] == 0)) )
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
    
    // groups
    if(enableGroups){
        [filteredGroupsList removeAllObjects];
        // check full following list
        for (Group *objGroup in fullGroupsList){
            // display name or username
            if (([objGroup.name rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)){
                [filteredGroupsList addObject:objGroup];
            }
        }
    }
    
    [noResultView setHidden:YES];
    // result exist
    if ((!enableGroups&&([fullFollowingList count] == 0)) ||
        (enableGroups && ([fullFollowingList count] == 0) && ([fullGroupsList count] == 0)) ){
        
        [noResultView setHidden:YES];
    }
    // reload table
    [usersTableView reloadData];
}

// Save mention list
- (void)saveMentionList{
    
    if(mentionType == kEventMentionToTimelineCollection)
        [self performSegueWithIdentifier:@"unwindEventMentionsSegue" sender:self];
    else if(mentionType == kEventMentionToChat )
        [self performSegueWithIdentifier:@"unwindMentionSegue" sender:self];
    else if(mentionType == kEventMentionToMap)
        [self performSegueWithIdentifier:@"unwindMapEventMentionsSegue" sender:self];
    else if(mentionType == kTimelineMentionToTimeline)
        [self performSegueWithIdentifier:@"unwindMentionSegue" sender:self];
    else if(mentionType == kEventMentionToCreateGroup)// back add group list
        [self performSegueWithIdentifier:@"unwindAddGroupSegue" sender:self];
}

- (NSMutableArray*) getAllMentionedUsersList{
    NSMutableArray *allMentionList = [[NSMutableArray alloc] init];
    // loop all friends and fetch ids
    for (Friend *obj in mentionedList)
        [allMentionList addObject:obj.objectId];
    if(enableGroups)
        for(Group *obj in mentionedGroupsList)
            for(Friend *member in obj.members)
                [allMentionList addObject:member.objectId];
    return allMentionList;
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
    return 2;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // hide header for first section
    return CELL_HEADER_HEIGHT;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // header section
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(14, 0, self.view.frame.size.width, CELL_HEADER_HEIGHT)];
    header.backgroundColor = [UIColor colorWithWhite:248.0/255.0 alpha:1.0];
    UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
    lbl.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    lbl.backgroundColor = [UIColor clearColor];
    // group section
    if (section == 0)
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_HEADER3"];
    else //following list section
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_HEADER2"];
    [header addSubview:lbl];
    int transform = 1;
    lbl.textAlignment = NSTextAlignmentLeft;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
    {
        transform = -1;
        lbl.textAlignment = NSTextAlignmentRight;
    }
    [lbl setTransform:CGAffineTransformMakeScale(transform, 1)];
    return header;
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
    if(section == 0)
        return [filteredList count];
    return [filteredGroupsList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"friendsListCell";
    static NSString *CellIdentifier2 = @"groupListCell";
    if(indexPath.section == 0){
        // timeline list cell
        FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Friend *friendObj = [filteredList objectAtIndex:indexPath.row];
        BOOL isMentioned = NO;
        for (Friend *obj in mentionedList){
            if ([obj.objectId isEqualToString:friendObj.objectId])
                isMentioned = YES;
        }
        [cell populateCellWithContent:friendObj withMention:isMentioned];
        return cell;
    }else{
        // timeline list cell
        MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        Group *groupObj = [filteredGroupsList objectAtIndex:indexPath.row];
        BOOL isMentioned = NO;
        for (Group *obj in mentionedGroupsList){
            if ([obj.objectId isEqualToString:groupObj.objectId])
                isMentioned = YES;
        }
        [cell populateGroupWithContent:groupObj withAdmin:YES];
        [cell setGroupSelected:isMentioned];
        return cell;
    }
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_selectionMode == SINGLE)
    {
        [mentionedList removeAllObjects];
        [mentionedGroupsList removeAllObjects];
    }
    
    if(indexPath.section == 0){
        Friend *friendObj = [filteredList objectAtIndex:indexPath.row];
        int friendIndex = -1;
        for (int i = 0; i < [mentionedList count]; i++)
        {
            Friend *obj = (Friend*)[mentionedList objectAtIndex:i];
            if ([obj.objectId isEqualToString:friendObj.objectId])
                friendIndex = i;
        }
        // remove mention
        if (friendIndex > -1)
            [mentionedList removeObjectAtIndex:friendIndex];
        else // add mention
            [mentionedList addObject:friendObj];
    }else{
        Group *grpObj = [filteredGroupsList objectAtIndex:indexPath.row];
        int grpIndex = -1;
        for (int i = 0; i < [mentionedGroupsList count]; i++)
        {
            Group *obj = (Group*)[mentionedGroupsList objectAtIndex:i];
            if ([obj.objectId isEqualToString:grpObj.objectId])
                grpIndex = i;
        }
        // remove mention
        if (grpIndex > -1)
            [mentionedGroupsList removeObjectAtIndex:grpIndex];
        else // add mention
            [mentionedGroupsList addObject:grpObj];
    }
    [usersTableView reloadData];
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

-(Group*)getFirstSelectedGroup{
    if(mentionedGroupsList){
        return [mentionedGroupsList firstObject];
    }
    return nil;
}

-(Friend*)getFirstSelectedFollower{
    if(mentionedList){
        return [mentionedList firstObject];
    }
    return nil;
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
