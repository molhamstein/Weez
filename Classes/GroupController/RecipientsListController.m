//
//  RecipientsListController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "RecipientsListController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "FriendListCell.h"
#import "MemberListCell.h"

@implementation RecipientsListController

@synthesize selectedFollowingList;
@synthesize selectedGroupList;
@synthesize isPublic;
@synthesize usersTableView;
@synthesize searchView;
@synthesize searchLabel;
@synthesize searchTextField;
@synthesize publicLabel;
@synthesize publicSwitch;
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
    // configure controls
    [self configureViewControls];
    selectedFollowingList = [[NSMutableArray alloc] init];
    selectedGroupList = [[NSMutableArray alloc] init];
    isPublic = YES;
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
    rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 44);
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_PICKER_OK"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveMentionList) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.6] forState:UIControlStateDisabled];
    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = barButton2;
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // set fonts
    [searchLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [publicLabel setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [searchTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_TITLE"];
    searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_DESC"];
    searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_PLACEHOLDER"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_NO_RESULT"];
    publicLabel.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_HEADER1"];
    // refresh right button
    [self refreshRightButton];
    [publicSwitch setOn:YES];
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

// Refresh right button
- (void)refreshRightButton
{
    [rightButton setEnabled:NO];
    if ((isPublic) || ([selectedFollowingList count] > 0) || ([selectedGroupList count] > 0))
        [rightButton setEnabled:YES];
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
    filteredFollowingList = [[NSMutableArray alloc] init];
    fullGroupList = [[NSMutableArray alloc] init];
    filteredGroupList = [[NSMutableArray alloc] init];
    // get following list
    [[ConnectionManager sharedManager] getRecipientsListRankedBy:RANK_BY_MENTION onSuccess:^(NSMutableArray *usersList, NSMutableArray* groupsList)
    {
        // stop loader
        [loaderView setHidden:YES];
        [searchTextField setEnabled:YES];
        // fill in data
        fullFollowingList = [[NSMutableArray alloc] initWithArray:usersList];
        fullGroupList = [[NSMutableArray alloc] initWithArray:groupsList];
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
    filteredFollowingList = [[NSMutableArray alloc] initWithArray:fullFollowingList];
    filteredGroupList = [[NSMutableArray alloc] initWithArray:fullGroupList];
    searchTextField.text = @"";
    [noResultView setHidden:YES];
    [usersTableView setHidden:NO];
    [usersTableView reloadData];
    // show empty view
    if (([fullFollowingList count] == 0) && ([fullGroupList count] == 0))
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
    [filteredFollowingList removeAllObjects];
    [filteredGroupList removeAllObjects];
    // check full following list
    for (Friend *objFriend in fullFollowingList)
    {
        // display name or username
        if (([objFriend.displayName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
            || ([objFriend.username rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound))
        {
            [filteredFollowingList addObject:objFriend];
        }
    }
    // check full group list
    for (Group *objGroup in fullGroupList)
    {
        // group name
        if ([objGroup.name rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [filteredGroupList addObject:objGroup];
        }
        else// search inside memebers
        {
            for (Friend *objMember in objGroup.members)
            {
                // members display name or username
                if (([objMember.displayName rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                    || ([objMember.username rangeOfString:searchTextField.text options:NSCaseInsensitiveSearch].location != NSNotFound))
                {
                    [filteredGroupList addObject:objGroup];
                    break;
                }
            }
        }
    }
    [noResultView setHidden:NO];
    [usersTableView setHidden:YES];
    // result exist
    if (([filteredFollowingList count] > 0) || ([filteredGroupList count] > 0))
    {
        [noResultView setHidden:YES];
        [usersTableView setHidden:NO];
    }
    // reload table
    [usersTableView reloadData];
}

// Switch change
- (IBAction)changeSwitch:(id)sender
{
    isPublic = publicSwitch.isOn;
    [self refreshRightButton];
}

// Save mention list
- (void)saveMentionList
{
    // back to recorded media
    [self performSegueWithIdentifier:@"unwindRecipientsSegue" sender:self];
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
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_HEADER2"];
    else //following list section
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"RECIPIENTS_LIST_HEADER3"];
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
    // groups section
    if (section == 0)
        return [filteredGroupList count];
    // following section
    return [filteredFollowingList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"memberListCell";
    static NSString *CellIdentifier2 = @"friendsListCell";
    // group list cell
    if (indexPath.section == 0)
    {
        MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Group *groupObj = [filteredGroupList objectAtIndex:indexPath.row];
        [cell populateGroupWithContent:groupObj withAdmin:NO];
        [cell.adminImageView setHidden:YES];
        if ([selectedGroupList containsObject:groupObj.objectId])
        {
            cell.adminImageView.image = [UIImage imageNamed:@"friendMentionIconActive"];
            [cell.adminImageView setHidden:NO];
        }
        return cell;
    }
    // following list cell
    else
    {
        // frient list cell
        FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        Friend *friendObj = [filteredFollowingList objectAtIndex:indexPath.row];
        BOOL isMentioned = NO;
        if ([selectedFollowingList containsObject:friendObj.objectId])
                isMentioned = YES;
        [cell populateCellWithContent:friendObj withMention:isMentioned];
        return cell;
    }
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_selectionMode == SINGLE)
    {
        [selectedGroupList removeAllObjects];
        [selectedFollowingList removeAllObjects];
    }
    
    // group list section
    if (indexPath.section == 0)
    {
        Group *groupObj = [filteredGroupList objectAtIndex:indexPath.row];
        // remove group
        if ([selectedGroupList containsObject:groupObj.objectId])
            [selectedGroupList removeObject:groupObj.objectId];
        else // add group
            [selectedGroupList addObject:groupObj.objectId];
    }
    // follwoing list section
    else
    {
        Friend *friendObj = [filteredFollowingList objectAtIndex:indexPath.row];
        // remove following
        if ([selectedFollowingList containsObject:friendObj.objectId])
            [selectedFollowingList removeObject:friendObj.objectId];
        else // add following
            [selectedFollowingList addObject:friendObj.objectId];
    }
    // refresh right button
    [self refreshRightButton];
    // reload data
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
    if(selectedGroupList){
        NSString *gId = [selectedGroupList firstObject];
        for (Group *g in fullGroupList) {
            if([g.objectId isEqualToString:gId])
                return g;
        }
    }
    return nil;
}

-(Friend*)getFirstSelectedFollower{
    if(selectedFollowingList){
        NSString *gId = [selectedFollowingList firstObject];
        for (Friend *g in fullFollowingList) {
            if([g.objectId isEqualToString:gId])
                return g;
        }
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
