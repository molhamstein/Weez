//
//  SearchController.m
//  Weez
//
//  Created by Molham on 01/09/16.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "SearchController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "FriendListCell.h"
#import "ProfileController.h"
#import "LocationListCell.h"
#import "TagListCell.h"
#import "TimelinesCollectionController.h"

@implementation SearchController

@synthesize usersTableView;
@synthesize searchView;
@synthesize searchLabel;
@synthesize searchTextField;
@synthesize noResultView;
@synthesize noResultLabel;
@synthesize backgroundButton;
@synthesize loaderView;
@synthesize usersTabButton;
@synthesize locationsTabButton;
@synthesize tagsTabButton;
@synthesize gallery;


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
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_ADD_FRIEND_TITLE"];
    searchLabel.text = [[AppManager sharedManager] getLocalizedString:@"ADD_FRIEND_DESC"];
    searchTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"ADD_FRIEND_PLACEHOLDER"];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"ADD_FRIEND_NO_RESULT"];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:searchView];
    [[AppManager sharedManager] flipViewDirection:usersTableView];
    
    searchTextField.delegate = self;
    [searchTextField addTarget:self action:@selector(textFieldDidChange)forControlEvents:UIControlEventEditingChanged];
    
    currentSearchMode = searchModeUsers;
    searchForTop = YES;
    [self performSearchForTop];
    // tabs
    usersTabButton.selected = YES;
    locationsTabButton.selected = NO;
    tagsTabButton.selected = NO;
    // prepare lists and clear data
    listOfUsers = [[NSMutableArray alloc] init];
    listOfLocations = [[NSMutableArray alloc] init];
    listOfTags = [[NSMutableArray alloc] init];
    [usersTableView setHidden:YES];
    [gallery setHidden:YES];

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

// Search for user
- (void)search:(NSString*)username
{
    // start loading
    [loaderView setHidden:NO];
    [searchTextField setEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    [noResultView setHidden:YES];
    // prepare lists and clear data
    listOfUsers = [[NSMutableArray alloc] init];
    // search keywords
    [[ConnectionManager sharedManager] searchForUser:username success:^(NSMutableArray *usersList)
    {
        // stop loader
        [self.view setUserInteractionEnabled:YES];
        [loaderView setHidden:YES];
        [gallery setHidden:YES];
        [searchTextField setEnabled:YES];
        // fill in data
        listOfUsers = [[NSMutableArray alloc] initWithArray:usersList];
        // reload table
        [usersTableView reloadData];
        [usersTableView setHidden:NO];
        // no result
        if ([listOfUsers count] == 0)
        {
            [noResultView setHidden:NO];
            [usersTableView setHidden:YES];
        }
    }
    failure:^(NSError *error)
    {
        // stop loader
        [self.view setUserInteractionEnabled:YES];
        [loaderView setHidden:YES];
        [searchTextField setEnabled:YES];
        // show notification error
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Follow user
- (void)followUser:(UIButton*)sender
{
    [sender setEnabled:NO];
    int rowIndex = (int)sender.tag;
    Friend *friendObj = [listOfUsers objectAtIndex:rowIndex];
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
        [sender setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:icon] forState:UIControlStateDisabled];
        [sender setTitle:@"" forState:UIControlStateNormal];
        
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

// Follow user
- (void)followLocation:(UIButton*)sender
{
    [sender setEnabled:NO];
    int rowIndex = (int)sender.tag;
    Location *location = [listOfLocations objectAtIndex:rowIndex];
    [[ConnectionManager sharedManager].userObject followLocation:location.objectId];
    // animate the pressed voted image
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
     {
         sender.alpha = 0.0;
         sender.transform = CGAffineTransformScale(sender.transform, 0.5, 0.5);
     }
                     completion:^(BOOL finished)
     {
         // follow/unfollow this location
         [sender setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateNormal];
         [sender setImage:[UIImage imageNamed:@"friendFollowIcon"] forState:UIControlStateDisabled];
         if ([location isFollowing])
         {
             [sender setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateNormal];
             [sender setImage:[UIImage imageNamed:@"friendFollowIconActive"] forState:UIControlStateDisabled];
         }
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
    [[ConnectionManager sharedManager] followLocation:location.objectId success:^(void)
     {
         // notify about timeline changes
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
         [[ConnectionManager sharedManager] getCurrentUser:^{
             User *me = [[ConnectionManager sharedManager] userObject];
             if([me isFollowingLocation:location.objectId]){
                 location.locationFollowers = location.locationFollowers +1;
             }else if(location.locationFollowers > 0){
                 location.locationFollowers = location.locationFollowers -1;
             }
             [self.usersTableView reloadData];
             [sender setEnabled:YES];
         } failure:^(NSError *error) {
             [sender setEnabled:YES];
         }];
     }
                                              failure:^(NSError * error)
     {
         [sender setEnabled:YES];
         [self.usersTableView reloadData];
     }];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark search Tabs
- (IBAction)didTapUsersSegment:(id)sender{
    [self switchSegment:searchModeUsers];
}
- (IBAction)didTapLocationsSegment:(id)sender{
    [self switchSegment:searchModeLocations];
    
}
- (IBAction)didTapTagsSegment:(id)sender{
    [self switchSegment:searchModeTags];
}

- (void) switchSegment:(SearchMode) newMode{
    if(currentSearchMode == newMode)
        return;
    
    NSString *keyWord = searchTextField.text;
    switch (newMode) {
        case searchModeUsers:
            // highlight selected tab
            usersTabButton.selected = YES;
            locationsTabButton.selected = NO;
            tagsTabButton.selected = NO;
            currentSearchMode = newMode;
            if(searchForTop)
                [self switchGalleryMode:searchModeUsers];
            else if(![keyWord isEqualToString:@""] && ![lastUsersSearchKeyword isEqualToString:keyWord])// dont perforsm search if the keyword havent changed since the last usesrs search we made
                [self performSearch:searchTextField.text];
            else
                [self refreshResultsViewWithItemsCount:[listOfUsers count]]; // juts display the current users arrray we have
            break;
        case searchModeLocations:
            // highlight selected tab
            usersTabButton.selected = NO;
            locationsTabButton.selected = YES;
            tagsTabButton.selected = NO;
            currentSearchMode = newMode;
            if(searchForTop)
                [self switchGalleryMode:searchModeLocations];
            else if(![keyWord isEqualToString:@""] && ![lastLocationsSearchKeyword isEqualToString:keyWord])// dont perforsm search if the keyword havent changed since the last locations search we made
                [self performSearch:searchTextField.text];
            else
                [self refreshResultsViewWithItemsCount:[listOfLocations count]]; // juts display the current locations arrray we have
            break;
        case searchModeTags:
            // highlight selected tab
            usersTabButton.selected = NO;
            locationsTabButton.selected = NO;
            tagsTabButton.selected = YES;
            currentSearchMode = newMode;
            if(searchForTop)
                [self switchGalleryMode:searchModeTags];
            else if(![keyWord isEqualToString:@""] && ![lastTagsSearchKeyword isEqualToString:keyWord])// dont perforsm search if the keyword havent changed since the last tags search we made
                [self performSearch:searchTextField.text];
            else
                [self refreshResultsViewWithItemsCount:[listOfTags count]]; // juts display the current tags arrray we have
            break;
    }
    
}

- (void) performSearch:(NSString *) keyWord{
    
    // start loading
    [loaderView setHidden:NO];
    [noResultView setHidden:YES];
    // used to be compared with the currentSearchMode when the data is recieved
    NSString *keyword = searchTextField.text;
    // search keywords
    [[ConnectionManager sharedManager] search:keyword
                                          for:currentSearchMode
                                      success:^(NSMutableArray *resultsList, SearchMode searchMode)
     {
         // stop loader
         [loaderView setHidden:YES];
         [searchTextField setEnabled:YES];
         
         if(currentSearchMode != searchMode)
             return;
         
         // fill data according to search mode
         if(searchMode == searchModeUsers){
             listOfUsers = [[NSMutableArray alloc] initWithArray:resultsList];
             lastUsersSearchKeyword = keyWord;
         }else if(searchMode == searchModeLocations){
             listOfLocations = [[NSMutableArray alloc] initWithArray:resultsList];
             lastLocationsSearchKeyword = keyWord;
         }else if(searchMode == searchModeTags){
             listOfTags = [[NSMutableArray alloc] initWithArray:resultsList];
             lastTagsSearchKeyword = keyWord;
         }
         
         // reload table
         [self refreshResultsViewWithItemsCount:[resultsList count]];
     }
                                      failure:^(NSError *error)
     {
         // stop loader
         [self.view setUserInteractionEnabled:YES];
         [loaderView setHidden:YES];
         [searchTextField setEnabled:YES];
         // show notification error
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
     }];
}

-(void) refreshResultsViewWithItemsCount:(long) count{
    // reload table
    [usersTableView reloadData];
    [gallery setHidden:YES];
    // no result
    if (count == 0){
        [noResultView setHidden:NO];
        [usersTableView setHidden:YES];
    }else{
        [noResultView setHidden:YES];
        [usersTableView setHidden:NO];
    }
}

#pragma mark -
#pragma mark Top Collection stuff
- (void) performSearchForTop{
    
    // start loading
    [loaderView setHidden:NO];
    [noResultView setHidden:YES];
    [[ConnectionManager sharedManager] searchForTop:
                                      ^(NSMutableDictionary *resultsList)
     {
         // stop loader
         [loaderView setHidden:YES];
         // fill data
         listOfUsers = [[NSMutableArray alloc] initWithArray:[resultsList objectForKey:@"USERS"]];
         listOfLocations = [[NSMutableArray alloc] initWithArray:[resultsList objectForKey:@"LOCATIONS"]];
         listOfTags = [[NSMutableArray alloc] initWithArray:[resultsList objectForKey:@"TAGS"]];
         //send data To Gallery view
         [gallery setData:listOfUsers];
         [gallery setDelegate:self];
         [self switchGalleryMode:searchModeUsers];
        
     }
                                      failure:^(NSError *error)
     {
         // stop loader
         [self.view setUserInteractionEnabled:YES];
         [loaderView setHidden:YES];
         // show notification error
         [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
     }];
}
-(void) refreshGalleryViewWithItemsCount:(long) count{
    // reload table
    [gallery reloadData];
    [usersTableView setHidden:YES];
    // no result
    if (count == 0){
        [noResultView setHidden:NO];
        [gallery setHidden:YES];
    }else{
        [noResultView setHidden:YES];
        [gallery setHidden:NO];
    }
}

-(void) switchGalleryMode : (SearchMode) mode
{
    //reload gallery according to selected section
    if(currentSearchMode == searchModeUsers){
        [gallery setGalleryType:GALLERY_USERS];
        [gallery setData:listOfUsers];
        [self refreshGalleryViewWithItemsCount:[listOfUsers count]];
    }else if(currentSearchMode == searchModeLocations){
        [gallery setGalleryType:GALLERY_LOACTIONS];
        [gallery setData:listOfLocations];
        [self refreshGalleryViewWithItemsCount:[listOfLocations count]];
    }else if(currentSearchMode == searchModeTags){
        [gallery setGalleryType:GALLERY_TAGS];
        [gallery setData:listOfTags];
        [self refreshGalleryViewWithItemsCount:[listOfTags count]];
    }
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
    switch (currentSearchMode) {
        case searchModeUsers:
            return [listOfUsers count];
            break;
        case searchModeLocations:
            return [listOfLocations count];
            break;
        case searchModeTags:
            return [listOfTags count];
            break;
    }
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"friendsListCell";
    static NSString *CellIdentifier2 = @"tagsListCell";
    static NSString *CellIdentifier3 = @"locationsListCell";
    
    UITableViewCell *cell;

    if(currentSearchMode == searchModeUsers){
        // timeline list cell
        FriendListCell *friendCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        cell = friendCell;
        Friend *friendObj = [listOfUsers objectAtIndex:indexPath.row];
        [friendCell populateCellWithContent:friendObj];
        // follow button
        friendCell.followButton.tag = indexPath.row;
        [friendCell.followButton addTarget:self action:@selector(followUser:) forControlEvents:UIControlEventTouchUpInside];
    }else if(currentSearchMode == searchModeLocations){
        LocationListCell *locationCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
        cell = locationCell;
        Location *locationObj = [listOfLocations objectAtIndex:indexPath.row];
        [locationCell populateCellWithContent:locationObj withFollow:YES];
        // follow button
        locationCell.followButton.tag = indexPath.row;
        [locationCell.followButton addTarget:self action:@selector(followLocation:) forControlEvents:UIControlEventTouchUpInside];
    }else if(currentSearchMode == searchModeTags){
        TagListCell *tagCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
        cell = tagCell;
        Tag *tagObj = [listOfTags objectAtIndex:indexPath.row];
        [tagCell populateCellWithContent:tagObj];
    }
    
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(currentSearchMode == searchModeUsers){
        selectedFriend = [listOfUsers objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"addFriendProfileSegue" sender:self];
        // deselect row for next touch
        [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
    }else if(currentSearchMode == searchModeLocations){
        selectedLocation = [listOfLocations objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"searchTimelinesCollectionSegue" sender:self];
        // deselect row for next touch
        [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
    }else if(currentSearchMode == searchModeTags){
        selectedTag = [listOfTags objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"searchTimelinesCollectionSegue" sender:self];
        // deselect row for next touch
        [usersTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    [self backgroundClick:nil];
}

-(void) textFieldDidChange{
    NSString *keyword = searchTextField.text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if([keyword isEqualToString:searchTextField.text] && ![keyword isEqualToString:@""]){
            [self performSearch:searchTextField.text];
            searchForTop = NO;
        }
    });
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // search for content
//    if ([textField.text length] > 0)
//        [self performSearch:searchTextField.text];
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
    if ([[segue identifier] isEqualToString:@"addFriendProfileSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        ProfileController *profileController = (ProfileController*)[navController viewControllers][0];
        [profileController setProfileWithFriend:selectedFriend];
    }else if ([[segue identifier] isEqualToString:@"searchTimelinesCollectionSegue"])
    {
        if(selectedLocation != nil){
            // pass the active user to profile page
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
            selectedLocation = nil;
        }else{
            // pass the active user to profile page
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeTagTimelines withLocation:nil withTag:selectedTag withEvent:nil];
            selectedTag = nil;
        }
    }
}


#pragma mark -
#pragma mark Gallery View Delegate
-(void) onFriendCellSelected:(Friend *)freind
{
    selectedFriend = freind;
    [self performSegueWithIdentifier:@"addFriendProfileSegue" sender:self];
}

-(void) onLocationCellSelected:(Location *)location
{
    selectedLocation = location;
    [self performSegueWithIdentifier:@"searchTimelinesCollectionSegue" sender:self];
}

-(void) onTagCellSelected:(Tag *)tag
{
    selectedTag = tag;
    [self performSegueWithIdentifier:@"searchTimelinesCollectionSegue" sender:self];
}

@end
