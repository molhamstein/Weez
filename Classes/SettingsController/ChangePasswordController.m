//
//  ChangePasswordController.m
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "ChangePasswordController.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@implementation ChangePasswordController

@synthesize changePassView;
@synthesize oldPassLabel;
@synthesize nPassLabel;
@synthesize confirmPassLabel;
@synthesize oldPassField;
@synthesize nPassField;
@synthesize confirmPassField;
@synthesize changePassButton;
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
    [changePassButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [oldPassLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [nPassLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [confirmPassLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [oldPassField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [nPassField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [confirmPassField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    oldPassField.tag = kChangeOldPassTag;
    nPassField.tag = kChangeNewPassTag;
    confirmPassField.tag = kChangeConfirmPassTag;
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"PREF_CHANGE_PSW"];
    oldPassLabel.text = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_OLD_FIELD"];
    nPassLabel.text = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_NEW_FIELD"];
    confirmPassLabel.text = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_CONFIRM_FIELD"];
    oldPassField.placeholder = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_OLD_PLACEHOLDER"];
    nPassField.placeholder = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_NEW_PLACEHOLDER"];
    confirmPassField.placeholder = [[AppManager sharedManager] getLocalizedString:@"CHANGE_PASSWORD_CONFIRM_PLACEHOLDER"];
    [changePassButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_CHANGE_PSW"] forState:UIControlStateNormal];
    [changePassButton setEnabled:NO];
    [changePassButton setAlpha:0.6];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:changePassView];
}

// Clear data
- (void)clearData
{
    oldPassField.text = @"";
    nPassField.text = @"";
    confirmPassField.text = @"";
    [changePassButton setEnabled:NO];
    [changePassButton setAlpha:0.6];
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

// Change pass action
- (IBAction)changePassAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // all data filled 
    if (([oldPassField.text length] > 0) && ([nPassField.text length] > 0) && ([confirmPassField.text length] > 0))
    {
        // password is too short
        if (([oldPassField.text length] < 6) || ([nPassField.text length] < 6) || ([confirmPassField.text length] < 6))
            [[AppManager sharedManager] showNotification:@"SIGNIN_PASSWORD_SHORT"  withType:kNotificationTypeFailed];
        // new & confirm password didn't match
        else if (! [nPassField.text isEqualToString:confirmPassField.text])
            [[AppManager sharedManager] showNotification:@"CHANGE_PASSWORD_NO_MATCH"  withType:kNotificationTypeFailed];
        else // signup process
        {
            // start loader
            [loaderView setHidden:NO];
            [changePassButton setEnabled:NO];
            [changePassButton setAlpha:0.6];
            [changePassView setUserInteractionEnabled:NO];
            [self processSignup];
        }
    }
}

// Process sign up
- (void)processSignup
{
    // change password process
    [[ConnectionManager sharedManager] changePassword:oldPassField.text withNewPass:nPassField.text success:^
    {
        // stop loader
        [loaderView setHidden:YES];
        [changePassView setUserInteractionEnabled:YES];
        [changePassButton setEnabled:YES];
        [changePassButton setAlpha:1.0];
        [self clearData];
        [[AppManager sharedManager] showNotification:@"CHANGE_PASSWORD_SUCCESS"  withType:kNotificationTypeSuccess];
        // go back to settings
        [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
    }
    failure:^(NSError *error, int errorCode)
    {
        // stop loader
        [loaderView setHidden:YES];
        [changePassView setUserInteractionEnabled:YES];
        [changePassButton setEnabled:YES];
        [changePassButton setAlpha:1.0];
        // error username or email
        if (errorCode == 1)
            [[AppManager sharedManager] showNotification:@"CHANGE_PASSWORD_NOT_CORRECT"  withType:kNotificationTypeFailed];
        else// connection
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
    }];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [oldPassField resignFirstResponder];
    [nPassField resignFirstResponder];
    [confirmPassField resignFirstResponder];
    // filled data
    [changePassButton setEnabled:NO];
    [changePassButton setAlpha:0.6];
    if (([oldPassField.text length] > 0) && ([nPassField.text length] > 0) && ([confirmPassField.text length] > 0))
    {
        [changePassButton setEnabled:YES];
        [changePassButton setAlpha:1.0];
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
        // old pass
        case kChangeOldPassTag:
        {
            [nPassField becomeFirstResponder];
            break;
        }
        // new pass
        case kChangeNewPassTag:
        {
            [confirmPassField becomeFirstResponder];
            break;
        }
        // confirm pass
        case kChangeConfirmPassTag:
        {
            [confirmPassField resignFirstResponder];
            // change pass action
            [self backgroundAction:nil];            
            [self changePassAction:nil];
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
