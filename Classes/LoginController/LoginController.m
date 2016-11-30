//
//  LoginController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "LoginController.h"
#import "IntroCollectionCell.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "HomeController.h"

@implementation LoginController

// login view
@synthesize loginView;
@synthesize facebookButton;
@synthesize signupButton;
@synthesize footerView;
@synthesize footerLabel;
@synthesize loaderView;
//login form
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize signinButton;
@synthesize forgetPassButton;
// intro view
@synthesize introCollectionView;
@synthesize introPager;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[ConnectionManager sharedManager] isUserLoggedIn])
    {
        [self goToLogin];
    }
    [[ConnectionManager sharedManager] getGlobalList:nil failure:nil];
    // configure views
    [self configureTutorialView];
    [loginView setHidden:YES];
    [introCollectionView setHidden:YES];
    [introPager setHidden:YES];
}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:introCollectionView];
    [[AppManager sharedManager] flipViewDirection:introPager];
    // check previous session data
    if ([[ConnectionManager sharedManager] isUserLoggedIn])
    {
        // hide login and view loader
        [loginView setHidden:YES];
        [facebookButton setHidden:YES];
        [signupButton setHidden:YES];
        [signinButton setHidden:YES];
        [footerView setHidden:YES];
        [loaderView setHidden:NO];
    }
}

// View did appear
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // check previous session data
    if ([[ConnectionManager sharedManager] isUserLoggedIn])
    {
        // go to login
        [self goToLogin];
    }
    else// tutorial view
    {
        [introCollectionView setHidden:NO];
        [introPager setHidden:NO];
    }
}

// Configure view
- (void)configureLoginView
{
    // set font
    [signinButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [forgetPassButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [facebookButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [signupButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [usernameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    
    usernameField.tag = kSigninUsernameTag;
    passwordField.tag = kSigninPasswordTag;
    facebookButton.layer.cornerRadius = LAYER_CORNER_RADIUS;
    signupButton.layer.cornerRadius = LAYER_CORNER_RADIUS;
    signinButton.layer.cornerRadius = LAYER_CORNER_RADIUS;
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    
    // set text
    [facebookButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_LOGIN_FACEBOOK"] forState:UIControlStateNormal];
    [signupButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_LOGIN_EMAIL"] forState:UIControlStateNormal];
    [forgetPassButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_RECOVERY_ACTION"] forState:UIControlStateNormal];
    usernameLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_FIELD"];
    passwordLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_FIELD"];
    usernameField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_PLACEHOLDER"];
    passwordField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_PLACEHOLDER"];
    [signinButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_LOGIN_ACTION"] forState:UIControlStateNormal];
    
    // styling TextFields
    usernameField.borderStyle = UITextBorderStyleNone;
    usernameField.layer.cornerRadius = LAYER_CORNER_RADIUS;
    usernameField.layer.masksToBounds = YES;
//    usernameField.backgroundColor = [UIColor clearColor];
//    usernameField.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:0.5]CGColor];
//    usernameField.layer.borderWidth = 1.0f;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    usernameField.leftView = leftView;
    usernameField.leftViewMode = UITextFieldViewModeAlways;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, usernameField.frame.size.height)];
    usernameField.rightView = rightView;
    usernameField.rightViewMode = UITextFieldViewModeAlways;
    // password field
    passwordField.borderStyle = UITextBorderStyleNone;
    passwordField.layer.cornerRadius = LAYER_CORNER_RADIUS;
    passwordField.layer.masksToBounds = YES;
//    passwordField.backgroundColor = [UIColor clearColor];
//    passwordField.layer.borderColor = [[UIColor colorWithWhite:0.6 alpha:0.5]CGColor];
//    passwordField.layer.borderWidth = 1.0f;
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, passwordField.frame.size.height)];
    passwordField.leftView = leftView;
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, passwordField.frame.size.height)];
    passwordField.rightView = rightView;
    passwordField.rightViewMode = UITextFieldViewModeAlways;
    
    // set footer text
    NSString *originalText = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_LOGIN_FOOTER"];
    NSMutableAttributedString *footerText = [[NSMutableAttributedString alloc] initWithString:originalText];
    // Sets the font color of last block characters to green.
    NSRange range = [originalText rangeOfString:@"?"];
    if (range.location == NSNotFound)
        range = [originalText rangeOfString:@"؟"];
    if (range.location != NSNotFound)
        [footerText addAttribute: NSForegroundColorAttributeName value:[[AppManager sharedManager] getColorType:kAppColorGreen] range: NSMakeRange(range.location + 1, originalText.length - range.location - 1)];
    [footerLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    footerLabel.attributedText = footerText;
    
    [signinButton setEnabled:NO];
    [signinButton setAlpha:0.6];
    [loaderView setHidden:YES];
}

// Configure tutorial view
- (void)configureTutorialView
{
    // fill data
    introInfo = @[@{@"title":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_TITLE1"], @"description":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_DESCRIPTION1"], @"image": @"introIcon1"},
                  @{@"title":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_TITLE2"], @"description":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_DESCRIPTION2"], @"image": @"introIcon2"},
                  @{@"title":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_TITLE3"], @"description":[[AppManager sharedManager] getLocalizedString:@"INTRO_PAGE_DESCRIPTION3"], @"image": @"introIcon3"}];
    // setup collecton view
    [self setupCollectionView];
}

// Setup collection
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [introCollectionView setPagingEnabled:YES];
    [introCollectionView setCollectionViewLayout:flowLayout];
}

// Finish tutorial
- (void)finishTutorial
{
    [introCollectionView setHidden:YES];
    [introPager setHidden:YES];
    // configure login view
    [self configureLoginView];
    loginView.alpha = 0.0;
    [loginView setHidden:NO];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
    {
        loginView.alpha = 1.0;
        introCollectionView.alpha = 0.0;
        introPager.alpha = 0.0;
    }
    completion:^(BOOL finished)
    {
        // hide tutorial
        [introCollectionView setHidden:YES];
        [introPager setHidden:YES];
    }];
}

// FB Login function
- (IBAction)login:(id)sender
{
    // hide login and view loader
    [loginView setHidden:NO];
    [facebookButton setHidden:YES];
    [signupButton setHidden:YES];
    [signinButton setHidden:YES];
    [footerView setHidden:YES];
    [loaderView setHidden:NO];
    [[ConnectionManager sharedManager] userLogIn:^
    {
        //register device for notification
        NSString* deviceId = [ConnectionManager sharedManager].deviceIdentifier;
        // device id exist
        if ([deviceId length] > 0)
        {
            [[ConnectionManager sharedManager] registerDeviceForNotification:deviceId success:^
            {
                [ConnectionManager sharedManager].userObject.deviceRegistered = YES;
                [[AppManager sharedManager] saveUserData:[ConnectionManager sharedManager].userObject];
            }
            failure:^(NSError *error)
            {
            }];
        }
        // go to login
        [self clearData];
        [self goToLogin];
    }
    failure:^(NSError *error)
    {
        [facebookButton setHidden:NO];
        [signupButton setHidden:NO];
        [signinButton setHidden:NO];
        [footerView setHidden:NO];
        [loaderView setHidden:YES];
        // show notification error
        [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Signin action
- (IBAction)signinAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // all data filled
    if (([usernameField.text length] > 0) && ([passwordField.text length] > 0))
    {
        // password is too short
        if ([passwordField.text length] < 6)
            [[AppManager sharedManager] showNotification:@"SIGNIN_PASSWORD_SHORT" withType:kNotificationTypeFailed];
        // check eamil address
        else if (! [[AppManager sharedManager] validateEmail:usernameField.text])
            [[AppManager sharedManager] showNotification:@"SIGNIN_EMAIL_ERROR" withType:kNotificationTypeFailed];
        else // signin process
        {
            // start loader
            [loaderView setHidden:NO];
            [signinButton setEnabled:NO];
            [signinButton setAlpha:0.6];
            [loginView setUserInteractionEnabled:NO];
            [self processSignin];
        }
    }
}

// Process sign in
- (void)processSignin
{
    // signin process
    [[ConnectionManager sharedManager] signinLogin:usernameField.text andPassword:passwordField.text success:^
     {
         //register device for notification
         NSString* deviceId = [ConnectionManager sharedManager].deviceIdentifier;
         NSString* myId = [[ConnectionManager sharedManager] userObject].objectId;
         // device id exist
         if (([deviceId length] > 0) && (myId != nil))
         {
             [[ConnectionManager sharedManager] registerDeviceForNotification:deviceId success:^
              {
                  [ConnectionManager sharedManager].userObject.deviceRegistered = YES;
                  [[AppManager sharedManager] saveUserData:[ConnectionManager sharedManager].userObject];
                  // stop loader
                  [loaderView setHidden:YES];
                  [loginView setUserInteractionEnabled:YES];
                  [signinButton setEnabled:YES];
                  [signinButton setAlpha:1.0];
                  [self clearData];
                  // go home
                  [self goToLogin];
              }
                                                                      failure:^(NSError *error)
              {
                  // stop loader
                  [loaderView setHidden:YES];
                  [loginView setUserInteractionEnabled:YES];
                  [signinButton setEnabled:YES];
                  [signinButton setAlpha:1.0];
                  [self clearData];
                  // go home
                  [self goToLogin];
              }];
         }
         else // go back to login
         {
             // stop loader
             [loaderView setHidden:YES];
             [loginView setUserInteractionEnabled:YES];
             [signinButton setEnabled:YES];
             [signinButton setAlpha:1.0];
             [self clearData];
             // go home
             [self goToLogin];
         }
     }
                                           failure:^(NSError *error, NSString *errorMsg)
     {
         // stop loader
         [loaderView setHidden:YES];
         [loginView setUserInteractionEnabled:YES];
         [signinButton setEnabled:YES];
         [signinButton setAlpha:1.0];
         // show notification error
         if([errorMsg isEqualToString:@"no_such_email"]){
             [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR_EMAIL" withType:kNotificationTypeFailed];
         }else if([errorMsg isEqualToString:@"incorrect_old_password"]){
             [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR_PSW" withType:kNotificationTypeFailed];
         }else{
             [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR" withType:kNotificationTypeFailed];
         }
     }];
}

// forget password action
- (IBAction)forgetPassAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    [self performSegueWithIdentifier:@"resetPasswordSegue" sender:self];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    // filled data
    [signinButton setEnabled:NO];
    [signinButton setAlpha:0.6];
    if (([usernameField.text length] > 0) && ([passwordField.text length] > 0))
    {
        [signinButton setEnabled:YES];
        [signinButton setAlpha:1.0];
    }
}

// Clear data
- (void)clearData{
    usernameField.text = @"";
    passwordField.text = @"";
    [signinButton setEnabled:NO];
    [signinButton setAlpha:0.6];
}

// Go to login
- (void)goToLogin
{
    // username was saved successfully
    if ([[[ConnectionManager sharedManager] userObject].username length] > 0)
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    else// pick username
        [self performSegueWithIdentifier:@"setUsernameSegue" sender:self];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// Number of rows
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [introInfo count];
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"introCollectionCell";
    IntroCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dic = [introInfo objectAtIndex:indexPath.row];
    // populate cell
    [cell populateCellWithContent:[dic objectForKey:@"image"] withTitle:[dic objectForKey:@"title"] withDescription:[dic objectForKey:@"description"]];
    return cell;
}

#pragma mark –
#pragma mark UICollectionViewDelegateFlowLayout
// Item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

// End scroll
- (void)scrollViewDidEndDecelerating:(UIScrollView*)sv
{
    introPager.currentPage = [self horizontalPageNumber:sv];
}

// End dragging
- (void)scrollViewDidEndDragging:(UIScrollView*)sv willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        introPager.currentPage = [self horizontalPageNumber:sv];
    if ((introPager.currentPage == 2) &&  ([self horizontalPageNumber:sv] == 2))
        [self finishTutorial];
}

// Get horizontal page number
- (NSInteger)horizontalPageNumber:(UIScrollView*)sv
{
    CGPoint contentOffset = sv.contentOffset;
    CGSize viewSize = sv.bounds.size;
    NSInteger horizontalPage = MAX(0.0, contentOffset.x / viewSize.width);
    return horizontalPage;
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    // check which is the active field
    switch (textField.tag)
    {
            // username
        case kSigninUsernameTag:
        {
            [passwordField becomeFirstResponder];
            break;
        }
            // confirm pass
        case kSigninPasswordTag:
        {
            [passwordField resignFirstResponder];
            // signin action
            [self backgroundAction:nil];
            [self signinAction:nil];
            break;
        }
        default:
        {
            [textField resignFirstResponder];
            break;
        }
    }
    return YES;
}

// Start typing in text field
- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    // set active field
    [AppManager sharedManager].activeField = textField;
}

// End typing in text field
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [AppManager sharedManager].activeField = nil;
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *segueId = [segue identifier];
    if([segueId isEqualToString:@"loginSegue"])
    {
        UINavigationController *navController = [segue destinationViewController];
        HomeController *homeController = (HomeController*)[navController viewControllers][0];
        [homeController setRecievedDeepLinkingNotification:appNotification];
    }
}

// Go back from settings after logout
- (IBAction)unwindLogoutSegue:(UIStoryboardSegue*)segue
{
    // show login view
    [self finishTutorial];
    // show login options
    [facebookButton setHidden:NO];
    [signupButton setHidden:NO];
    [signinButton setHidden:NO];
    [footerView setHidden:NO];
    [loaderView setHidden:YES];
}

#pragma mark -
#pragma mark - Notification handling
- (void)setRecievedNotification:(AppNotification*)data
{
    appNotification = data;
}
@end
