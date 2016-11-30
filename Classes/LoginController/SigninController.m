//
//  SigninController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "SigninController.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@implementation SigninController

@synthesize loginView;
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize signinButton;
@synthesize forgetPassButton;
@synthesize loaderView;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];    
    // configure controls
    [self configureViewControls];
    // clear view
    [self clearData];
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
    [signinButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [forgetPassButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    usernameField.tag = kSigninUsernameTag;
    passwordField.tag = kSigninPasswordTag;
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_SIGNIN_TITLE"];
    [forgetPassButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_RECOVERY_ACTION"] forState:UIControlStateNormal];
    usernameLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_FIELD"];
    passwordLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_FIELD"];
    usernameField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_PLACEHOLDER"];
    passwordField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_PLACEHOLDER"];
    [signinButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNIN_LOGIN_ACTION"] forState:UIControlStateNormal];
    [signinButton setEnabled:NO];
    [signinButton setAlpha:0.6];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:loginView];
}

// Clear data
- (void)clearData
{
    usernameField.text = @"";
    passwordField.text = @"";
    [signinButton setEnabled:NO];
    [signinButton setAlpha:0.6];
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
                // go back to login
                [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
            }
            failure:^(NSError *error)
            {
                // stop loader
                [loaderView setHidden:YES];
                [loginView setUserInteractionEnabled:YES];
                [signinButton setEnabled:YES];
                [signinButton setAlpha:1.0];
                // go back to login
                [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
            }];
        }
        else // go back to login
        {
            // stop loader
            [loaderView setHidden:YES];
            [loginView setUserInteractionEnabled:YES];
            [signinButton setEnabled:YES];
            [signinButton setAlpha:1.0];
            [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
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
        [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR" withType:kNotificationTypeFailed];
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

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

@end
