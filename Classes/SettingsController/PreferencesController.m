//
//  SettingsController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "PreferencesController.h"
#import "AppManager.h"
#import "AppDelegate.h"
#import "ConnectionManager.h"
#import "SettingsItemCell.h"

typedef enum {
    pickerTypeLang = 0,
    pickerTypeImageViewDuration = 1,
    pickerTypeChatPrivacy= 2
}PICKER_TYPE;

@implementation PreferencesController

@synthesize tableView;
@synthesize selectorView;
@synthesize pickerView;
@synthesize selectorNavigationItem;
@synthesize selectorBgImage;
@synthesize selectorRightButton;
@synthesize btnLogout;


#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad{
    [super viewDidLoad];    
    // configure controls
    [self configureViewControls];
    [self configurePickerView];
    selectorView.hidden = YES;
    [self hidePicker:nil];
}

// Configure view controls
- (void)configureViewControls{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"PREF_TITLE_PREF"];
    
    // init data
    currentChatPrivacyLevel = [ConnectionManager sharedManager].userObject.chatPrivacyLevel;
    
    // tableView
    /// make sure sticky headers and fotters dont scroll out of screen like normal cells
    CGFloat dummyViewHeight = 40;
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyViewHeight)];
    self.tableView.tableHeaderView = dummyView;
    
    CGFloat dummyFooterViewHeight = 100;
    UIView *dummyFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, dummyFooterViewHeight)];
    self.tableView.tableFooterView = dummyFooterView;
    
    self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, -dummyFooterViewHeight, 0);
    [[AppManager sharedManager] flipViewDirection:self.tableView];
    
    // logout button
    self.btnLogout.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontTitle];
    [self.btnLogout setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_LOGOUT"] forState:UIControlStateNormal];
}

// Cancel action
- (void)cancelAction{
    // dismiss view
    [self.navigationController popViewControllerAnimated:YES];
}

// Receive memory warning
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark picker
- (void)configurePickerView{
    
//    [languageView setHidden:YES];
//    CGRect newFrame = self.languageView.frame;
//    newFrame.origin.y += PICKER_HEIGHT;
//    self.languageView.frame = newFrame;
    [self.selectorBgImage setAlpha:0.0];
    [self.selectorBgImage setHidden:YES];
    // left button
    UIButton *leftButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 80, 44);
    leftButton.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    [leftButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_PICKER_CANCEL"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(hidePicker:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    selectorNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    // right button
    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
    rightButton.frame = CGRectMake(0, 0, 80, 44);
    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_PICKER_OK"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    selectorNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // set title
    UILabel *title = [[UILabel  alloc] initWithFrame:CGRectMake(0, 0, 220, 44)];
    title.textAlignment = NSTextAlignmentCenter;
    [title setText:[[AppManager sharedManager] getLocalizedString:@"PREF_LANG"]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    selectorNavigationItem.titleView = title;
    //selectorNavigationItem.title = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG"];
    
}

// Show picker
- (IBAction)showPicker:(id)sender{
    
    [tableView setUserInteractionEnabled:NO];
    selectorView.hidden = NO;
    self.pickerTopConstraint.constant = 0;
    self.pickerBottomConstraint.constant = 0;
    [self.selectorView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.selectorView layoutIfNeeded];
        [self.selectorBgImage setAlpha:0.4];
    }];
}

// Hide picker
- (IBAction)hidePicker:(id)sender{

    self.pickerTopConstraint.constant = self.selectorView.frame.size.height;
    self.pickerBottomConstraint.constant = -self.selectorView.frame.size.height;
    [self.selectorView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.selectorView layoutIfNeeded];
        [self.selectorBgImage setAlpha:0.0];
    } completion:^(BOOL finished) {
        [tableView setUserInteractionEnabled:YES];
    }];
}

// Select language
- (void)select:(id)sender{
    int selectionIndex = (int) [pickerView selectedRowInComponent:0];
    if(pickerView.tag == pickerTypeImageViewDuration){
        NSInteger newDuration = 3;
        switch (selectionIndex) {
            case 0:
                newDuration = 3;
                break;
            case 1:
                newDuration = 6;
                break;
            case 2:
                newDuration = 8;
                break;
        }
        [self setImageDuration:newDuration];
    }else if(pickerView.tag == pickerTypeChatPrivacy){
        if (selectionIndex >= 0){
            AppChatPrivacyLevel newPrivacyLevel;
            if (selectionIndex == 0)
                newPrivacyLevel = kChatPrivacyLevelAll;
            else if (selectionIndex == 1)
                newPrivacyLevel = kChatPrivacyLevelFollowers;
            else
                newPrivacyLevel = kChatPrivacyLevelFollowersAndFollowing;
            
            [self setChatPrivacyLevel:newPrivacyLevel];
            [self.tableView reloadData];
        }
    }else{
        if (selectionIndex >= 0){
            AppLanguageType newLang;
            if (selectionIndex == 0)
                newLang = kAppLanguageEN;
            else
                newLang = kAppLanguageAR;
            
            //[self refreshLanguage];
            [[AppManager sharedManager] changeAppLanguage:newLang];
            [self changeLang:newLang];
            [self.tableView reloadData];
        }
    }
    
    // hide the picker
    [self hidePicker:sender];
}

#pragma mark -
#pragma mark Table view data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 2;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CELL_HEADER_HEIGHT;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
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
            lbl.text = [[AppManager sharedManager] getLocalizedString:@"PREF_TITLE_PREF"];
            break;
        case 1:
            lbl.text = [[AppManager sharedManager] getLocalizedString:@"PREF_TITLE_NOTIFICATIONS"];
            break;
    }
    [header addSubview:lbl];
    [header addSubview:seperatorView];
    int transform = 1;
    lbl.textAlignment = NSTextAlignmentLeft;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR){
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
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    // add footer view
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    footer.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0];
//    UIView *gradTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 8)];
//    
//    CAGradientLayer *gradientTop = [CAGradientLayer layer];
//    gradientTop.frame = gradTop.bounds;
//    gradientTop.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.1] CGColor],
//                          (id)[[UIColor colorWithWhite:0.0 alpha:0.06] CGColor],
//                          (id)[[UIColor colorWithWhite:0.0 alpha:0.03] CGColor],
//                          (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor], nil];
//    [gradTop.layer insertSublayer:gradientTop atIndex:0];
//    [footer addSubview:gradTop];
//    
//    if(section == 0){
//        UIView *gradBottom = [[UIView alloc]initWithFrame:CGRectMake(0, 42, self.view.frame.size.width, 8)];
//        CAGradientLayer *gradientBottom = [CAGradientLayer layer];
//        gradientBottom.frame = gradBottom.bounds;
//        gradientBottom.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor],
//                                 (id)[[UIColor colorWithWhite:0.0 alpha:0.03] CGColor],
//                                 (id)[[UIColor colorWithWhite:0.0 alpha:0.06] CGColor],
//                                 (id)[[UIColor colorWithWhite:0.0 alpha:0.1] CGColor], nil];
//        [gradBottom.layer insertSublayer:gradientBottom atIndex:0];
//        [footer addSubview:gradBottom];
//    }
    
    return footer;
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_SETTINGS_HEIGHT;

}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section == 0)
        return 3; // return 4 to show language options
    else
        return 4;
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier1 = @"CellPrefsItem";
    // timeline list cell
    SettingsItemCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    BOOL enableDecoration = YES;
    BOOL enableCount = YES;
    NSString *title = @"";
    NSString *count = @"0";
    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                enableDecoration = NO;
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_IMG_DURATION"];
                count = [NSString stringWithFormat:@"%d",[ConnectionManager sharedManager].userObject.imageDuration];
            break;
            case 1:
                enableDecoration = NO;
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY"];
                switch (currentChatPrivacyLevel) {
                    case kChatPrivacyLevelAll:
                        count = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_ALL"];
                        break;
                    case kChatPrivacyLevelFollowers:
                        count = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_FOLLOWERS_ONLY"];
                        break;
                    case kChatPrivacyLevelFollowersAndFollowing:
                        count = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_FOLLWING_AND_FOLLWERS"];
                    break;
                }
                
                break;
            case 2:
                enableDecoration = NO;
                enableCount = NO;
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_PRIVATE_PROFILE"];
                BOOL switchValue = [ConnectionManager sharedManager].userObject.isPrivate;
                [cell populateCellWithSwitch:title enableSwitch:switchValue];
                [cell.switchView addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
                break;
            case 3:
                enableCount = NO;
                enableDecoration = NO;
                if([AppManager sharedManager].appLanguage == kAppLanguageAR)
                    title = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG_AR"];
                else
                    title = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG_EN"];
                break;
        }
        
        cell.switchView.tag = indexPath.row;
        cell.switchView.viewForBaselineLayout.tag = indexPath.section;
        
        if(indexPath.row != 2)
        [cell populateCellWithContent:title count:count enableCount:enableCount decorationArrow:enableDecoration];
        
    }else{
        enableDecoration = NO;
        enableCount = NO;
        BOOL switchValue = NO;
        switch (indexPath.row) {
            case 0:
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_NOTIFICATION_BOOSTS"];
                switchValue = [ConnectionManager sharedManager].userObject.notificationsFlagBoosts;
                break;
            case 1:
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_NOTIFICATION_MENTIONS"];
                switchValue = [ConnectionManager sharedManager].userObject.notificationsFlagMentions;
                break;
            case 2:
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_NOTIFICATION_GRP_MSG"];
                switchValue = [ConnectionManager sharedManager].userObject.notificationsFlagMessages;
                break;
            case 3:
                title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_NOTIFICATION_NEW_FOLLOWER"];
                switchValue = [ConnectionManager sharedManager].userObject.notificationsFlagFollowers;
                break;
        }
        [cell populateCellWithSwitch:title enableSwitch:switchValue];
        cell.switchView.tag = indexPath.row;
        cell.switchView.viewForBaselineLayout.tag = indexPath.section;
        [cell.switchView addTarget:self action:@selector(setSwitchState:) forControlEvents:UIControlEventValueChanged];
    
    }
    
    // remove margin
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        [cell setSeparatorInset:UIEdgeInsetsZero];
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
        [cell setLayoutMargins:UIEdgeInsetsZero];
    //[cell populateCellWithContent:title count:@"10" enableCount:enableCount decorationArrow:enableDecoration];
    
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) { // this is my date cell above the picker cell
        UILabel *lbl = (UILabel*)selectorNavigationItem.titleView;
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"PREF_IMG_DURATION_TITLE"] ;
        self.pickerView.tag = pickerTypeImageViewDuration;
        [pickerView reloadAllComponents];
        [self showPicker:nil];
    } else if(indexPath.section == 0 && indexPath.row == 1) { // this is data cell above the picker cell
        UILabel *lbl = (UILabel*)selectorNavigationItem.titleView;
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY"] ;
        self.pickerView.tag = pickerTypeChatPrivacy;
        [pickerView reloadAllComponents];
        [self showPicker:nil];
    } else if (indexPath.section == 0 && indexPath.row == 3) { // this is language picker
        UILabel *lbl = (UILabel*)selectorNavigationItem.titleView;
        lbl.text = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG"] ;
        self.pickerView.tag = pickerTypeLang;
        [pickerView reloadAllComponents];
        [self showPicker:nil];
    }
}


#pragma mark -
#pragma mark - Picker
// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *title = @"";
    if(self.pickerView.tag == pickerTypeImageViewDuration){
        switch (row) {
            case 0:
                title = @"3";
                break;
            case 1:
                title = @"6";
                break;
            case 2:
                title = @"8";
                break;
        }
    }else if(self.pickerView.tag == pickerTypeChatPrivacy){
        switch (row) {
            case 0:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_ALL"];
                break;
            case 1:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_FOLLOWERS_ONLY"];
                break;
            case 2:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_CHAT_PRIVACY_FOLLWING_AND_FOLLWERS"];
                break;
        }
    }else{
        switch(row) {
            case 0:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG_EN"];
                break;
            case 1:
                title = [[AppManager sharedManager] getLocalizedString:@"PREF_LANG_AR"];
                break;
        }
    }
    return  title;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(self.pickerView.tag == pickerTypeImageViewDuration)
        return 3;
    else if(self.pickerView.tag == pickerTypeChatPrivacy)
        return 3;
    else
        return 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark -
#pragma mark - Switches
- (void)setSwitchState:(id)sender{
    
    BOOL state = [sender isOn];
    User *me = [[ConnectionManager sharedManager].userObject copyWithZone:nil];
    int tag = (int)((UIView*)sender).tag;
    int section = (int)((UISwitch*)sender).viewForBaselineLayout.tag;
    if(section == 0)//prefrences section
    {
        me.isPrivate = state;
    }
    else //notification section
    {
    switch (tag) {
        case 0:
            me.notificationsFlagBoosts = state;
            break;
        case 1:
            me.notificationsFlagMentions = state;
            break;

        case 2:
            me.notificationsFlagMessages = state;
            break;

        case 3:
            me.notificationsFlagFollowers = state;
            break;
    }
    }
    // change system notification type
    [[AppDelegate sharedDelegate] changeRemoteNotification];
    // update user info
    [[ConnectionManager sharedManager] updateUserInfo:me withImage:nil success:^{
        [tableView reloadData];
    } failure:^(NSError *error, int errorCode) {
        //[[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

#pragma mark -
#pragma mark - Chat Settings
- (void)setChatPrivacyLevel:(AppChatPrivacyLevel)newPrivacyLevel{
    
    if(newPrivacyLevel == currentChatPrivacyLevel)
        return;
    
    User *me = [[ConnectionManager sharedManager].userObject copyWithZone:nil];
    me.chatPrivacyLevel = newPrivacyLevel;
    
    // change system notification type
    [[AppDelegate sharedDelegate] changeRemoteNotification];
    // update user info
    [[ConnectionManager sharedManager] updateUserInfo:me withImage:nil success:^{
        currentChatPrivacyLevel = [ConnectionManager sharedManager].userObject.chatPrivacyLevel;
        [tableView reloadData];
    } failure:^(NSError *error, int errorCode) {
        //[[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
    currentChatPrivacyLevel = newPrivacyLevel;
}

#pragma mark -
#pragma mark - ACTIONS
- (void)changeLang:(AppLanguageType)newlang {
    // change language
    [[AppManager sharedManager] changeAppLanguage:newlang];
    // change navigation bar style
    dispatch_async(dispatch_get_main_queue(),^{
        [[AppManager sharedManager] setNavigationBarStyle];
        NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
        [titleBarAttributes setValue:[[AppManager sharedManager] getFontType:kAppFontLogo] forKey:NSFontAttributeName];
        [self.navigationController.navigationBar setTitleTextAttributes:titleBarAttributes];
        //selectorNavigationItem.titleView
        //[selectorNavigationItem appearance] setTitleTextAttributes
        // notify about language changes
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LANGUAGE_CHANGED object:nil userInfo:nil];
    });
    // refresh current view
    [self configureViewControls];
    [self configurePickerView];
}

// Background actionf

- (IBAction)logout:(id)sender{
    [[ConnectionManager sharedManager] userLogout];
    [self performSegueWithIdentifier:@"unwindLogoutSegue" sender:self];
}

-(void) setImageDuration:(NSInteger) newDuration{
    //[ConnectionManager sharedManager].userObject.imageDuration = (int) newDuration;
    User * me = [[ConnectionManager sharedManager].userObject copyWithZone:nil];
    me.imageDuration = (int) newDuration;
    [[ConnectionManager sharedManager] updateUserInfo:me withImage:nil success:^{
        [tableView reloadData];
    } failure:^(NSError *error, int errorCode) {
        //[[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
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
