//
//  ResetPasswordController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "ResetPasswordController.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@implementation ResetPasswordController

@synthesize recoveryView;
@synthesize recoveryLabel;
@synthesize emailLabel;
@synthesize numberLabel;
@synthesize emailTextField;
@synthesize numberTextField;
@synthesize recoveryButton;
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
    [recoveryButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [recoveryLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [emailLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [numberLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [emailTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [numberTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_RESET_PASSWORD_TITLE"];
    recoveryLabel.text = [[AppManager sharedManager] getLocalizedString:@"RESET_RECOVERY_DESC"];
    emailLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_FIELD"];
    numberLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER_FIELD"];
    emailTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_PLACEHOLDER"];
    numberTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER_PLACEHOLDER"];
    [recoveryButton setTitle:[[AppManager sharedManager] getLocalizedString:@"RESET_RECOVERY_ACTION"] forState:UIControlStateNormal];
    [recoveryButton setEnabled:NO];
    [recoveryButton setAlpha:0.6];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:recoveryView];
}

// Clear data
- (void)clearData
{
    emailTextField.text = @"";
    numberTextField.text = @"";
    [recoveryButton setEnabled:NO];
    [recoveryButton setAlpha:0.6];
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

// Recovery action
- (IBAction)recoveryAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    BOOL isOk = NO;
    // check email address
    if ([emailTextField.text length] > 0)
    {
        // valid email
        if ([[AppManager sharedManager] validateEmail:emailTextField.text])
            isOk = YES;
        else // notification
            [[AppManager sharedManager] showNotification:@"SIGNIN_EMAIL_ERROR" withType:kNotificationTypeFailed];
    }
    // check number
    else if ([numberTextField.text length] > 0)
        isOk = YES;
    // reset password process
    if (isOk)
    {
        // start loader
        [loaderView setHidden:NO];
        [recoveryButton setEnabled:NO];
        [recoveryButton setAlpha:0.6];
        [recoveryView setUserInteractionEnabled:NO];
        // process recovery
        [self processRecovery];
    }
}

// Process recovery
- (void)processRecovery
{
    // signin process
    [[ConnectionManager sharedManager] resetPassword:emailTextField.text withNumber:numberTextField.text success:^
    {
        // stop loader
        [loaderView setHidden:YES];
        [recoveryButton setEnabled:YES];
        [recoveryButton setAlpha:1.0];
        [recoveryView setUserInteractionEnabled:YES];
        // succeed
        [self clearData];
        // show notification
        [[AppManager sharedManager] showNotification:@"RESET_RECOVERY_SUCCESS" withType:kNotificationTypeSuccess];
    }
    failure:^(NSError *error, int errorCode)
    {
        // stop loader
        [loaderView setHidden:YES];
        [recoveryButton setEnabled:YES];
        [recoveryButton setAlpha:1.0];
        [recoveryView setUserInteractionEnabled:YES];
        // show notification for email error
        if (errorCode == 1)
            [[AppManager sharedManager] showNotification:@"RESET_EMAIL_ERROR" withType:kNotificationTypeFailed];
        // number error
        else if (errorCode == 2)
            [[AppManager sharedManager] showNotification:@"RESET_NUMBER_ERROR" withType:kNotificationTypeFailed];
        else// connection error
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [emailTextField resignFirstResponder];
    [numberTextField resignFirstResponder];
    // filled data
    [recoveryButton setEnabled:NO];
    [recoveryButton setAlpha:0.6];
    if (([emailTextField.text length] > 0) || ([numberTextField.text length] > 0))
    {
        [recoveryButton setEnabled:YES];
        [recoveryButton setAlpha:1.0];
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
    [textField resignFirstResponder];
    // recovery action
    [self backgroundAction:nil];
    [self recoveryAction:nil];
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
