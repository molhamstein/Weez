//
//  SettingsController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "SettingsController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "SettingsItemCell.h"
#import "FollowingListController.h"


@implementation SettingsController

@synthesize settingsTableView;


#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];    
    // configure controls
    [self configureViewControls];

}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    // refresh current user
    [[ConnectionManager sharedManager] getCurrentUser:^
    {
        [settingsTableView reloadData];        
    }
    failure:^(NSError *error)
    {
    }];
    [settingsTableView reloadData];
    [[AppManager sharedManager] flipViewDirection:settingsTableView];
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_SETTINGS_TITLE"];
    
    //self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_SETTINGS_TITLE"];
    
    // tableView
    /// make sure sticky headers and fotters dont scroll out of screen like normal cells
    CGFloat dummyViewHeight = 40;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.settingsTableView.bounds.size.width, dummyViewHeight)];
    self.settingsTableView.tableHeaderView = dummyView;
    
    CGFloat dummyFooterViewHeight = 100;
    UIView *dummyFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.settingsTableView.bounds.size.width, dummyFooterViewHeight)];
    self.settingsTableView.tableFooterView = dummyFooterView;
    
    self.settingsTableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, -dummyFooterViewHeight, 0);
    // remove separator insets
    if ([settingsTableView respondsToSelector:@selector(setSeparatorInset:)])
        [settingsTableView setSeparatorInset:UIEdgeInsetsZero];
    if ([settingsTableView respondsToSelector:@selector(setLayoutMargins:)])
        [settingsTableView setLayoutMargins:UIEdgeInsetsZero];
    //[settingsTableView setAllowsSelection:NO];
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return CELL_HEADER_HEIGHT;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, CELL_HEADER_HEIGHT)];
    header.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:header.frame];
    lbl.font = [[AppManager sharedManager] getFontType:kAppFontSubtitleBold];
    lbl.backgroundColor = [UIColor clearColor];
    
    CGRect sepFrame = CGRectMake(0, header.frame.size.height-1, header.frame.size.width, 1);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [UIColor colorWithWhite:248.0/255.0 alpha:1.0];
    
    switch (section) {
        case 0:
            lbl.text = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_PROFILE_SETTINGS"];
            break;
        case 1:
            lbl.text = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_APP_SETTINGS"];
            break;
    }
    [header addSubview:lbl];
    [header addSubview:seperatorView];
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
    return 50.00f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // add footer view
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    footer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0];
//    UIView *gradTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
//    
//    CAGradientLayer *gradientTop = [CAGradientLayer layer];
//    gradientTop.frame = gradTop.bounds;
//    gradientTop.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.1] CGColor],
//                                                    (id)[[UIColor colorWithWhite:0.0 alpha:0.06] CGColor],
//                                                    (id)[[UIColor colorWithWhite:0.0 alpha:0.03] CGColor],
//                                                    (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], nil];
//    [gradTop.layer insertSublayer:gradientTop atIndex:0];
//    [footer addSubview:gradTop];
//    
//    if(section == 0){
//        UIView *gradBottom = [[UIView alloc]initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, 8)];
//        CAGradientLayer *gradientBottom = [CAGradientLayer layer];
//        gradientBottom.frame = gradBottom.bounds;
//        gradientBottom.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor],
//                                                            (id)[[UIColor colorWithWhite:0.0 alpha:0.03] CGColor],
//                                                            (id)[[UIColor colorWithWhite:0.0 alpha:0.06] CGColor],
//                                                            (id)[[UIColor colorWithWhite:0.0 alpha:0.1] CGColor], nil];
//        [gradBottom.layer insertSublayer:gradientBottom atIndex:0];
//        [footer addSubview:gradBottom];
//    }
    
    return footer;
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // normal cell
    return CELL_SETTINGS_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        // admin user
        if ([[ConnectionManager sharedManager] userObject].isAdmin)
            return 6;
        return 4;
    }
    else
        return 2;
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"CellSettingsItem";
    // timeline list cell
    SettingsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    BOOL enableDecoration = YES;
    BOOL enableCount = YES;
    NSString *title = @"";
    NSString *count = @"";
    long listCount = 0;
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_FOLLOWERS"];
                listCount = [[ConnectionManager sharedManager].userObject.followersList count];
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
            case 1:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_FOLLOWING"];
                listCount = [[ConnectionManager sharedManager].userObject.followingsList count];
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
            case 2:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_MENTIONS"];
                listCount = [ConnectionManager sharedManager].userObject.mentionsCount;
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
            case 3:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_GROUPS"];
                listCount = [ConnectionManager sharedManager].userObject.groupsCount;
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
            case 4:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_LOCATIONS"];
                listCount = [ConnectionManager sharedManager].userObject.locationsCount;
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
            case 5:
            {
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_EVENTS"];
                listCount = [ConnectionManager sharedManager].userObject.eventsCount;
                if (listCount > 0)
                    count = [NSString stringWithFormat:@"%lu",listCount];
                break;
            }
        }
        cell.titleLable.textColor = [UIColor blackColor];
    }else{
        enableDecoration = NO;
        enableCount = NO;
        switch (indexPath.row) {
//            case 0:
//                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_EDIT"];
//                cell.titleLable.textColor = [UIColor blackColor];
//                break;
            case 0:
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_SECURITY"];
                cell.titleLable.textColor = [UIColor blackColor];
                break;
            case 1:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_LOGOUT"];
                cell.titleLable.textColor = [[AppManager sharedManager] getColorType:kAppColorRed];
                break;
        }
    }
    // remove margin
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    [cell populateCellWithContent:title count:count enableCount:enableCount decorationArrow:enableDecoration];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Info section
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:// follower list
            {
                followType = kFollowTypeFollowers;
                [self performSegueWithIdentifier:@"settingsFollowingListSegue" sender:self];
                break;
            }
            case 1:// following list
            {
                followType = kFollowTypeFollowing;
                [self performSegueWithIdentifier:@"settingsFollowingListSegue" sender:self];
                break;
            }
            case 2:// mention List
            {
                [self performSegueWithIdentifier:@"settingsMentionListSegue" sender:self];
                break;
            }
            case 3:// group List
            {
                [self performSegueWithIdentifier:@"settingsGroupListSegue" sender:self];
                break;
            }
            case 4:// location list
            {
                [self performSegueWithIdentifier:@"settingsLocationsSegue" sender:self];
                break;
            }
            case 5:// events list
            {
                [self performSegueWithIdentifier:@"settingsEventsSegue" sender:self];
                break;
            }
            default:
            {
                
            }
        }
    }
    // Preferences section
    else if (indexPath.section == 1){
        switch (indexPath.row) {
//            case 0:
//                [self performSegueWithIdentifier:@"settingsEditProfileSegue" sender:self];
//                break;
            case 0:
                [self performSegueWithIdentifier:@"settingsPreferencesSegue" sender:self];
                break;
            case 1:
                [[ConnectionManager sharedManager] userLogout];
                [self performSegueWithIdentifier:@"unwindLogoutSegue" sender:self];
                break;
        }
    }
}


#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"settingsFollowingListSegue"])
    {
        // pass the active user to profile page
        FollowingListController *profileController = (FollowingListController*)[segue destinationViewController];
        [profileController setFollowType:followType];
    }
}

@end
