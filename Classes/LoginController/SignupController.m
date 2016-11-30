//
//  SignupController.m
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "SignupController.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@implementation SignupController

@synthesize signupView;
@synthesize emailLabel;
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize numberLabel;
@synthesize emailField;
@synthesize usernameField;
@synthesize passwordField;
@synthesize numberField;
@synthesize signupButton;
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
    [signupButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [emailLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [numberLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [emailField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [passwordField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [numberField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    emailField.tag = kSignupEmailTag;
    usernameField.tag = kSignupUsernameTag;
    passwordField.tag = kSignupPasswordTag;
    numberField.tag = kSignupNumberTag;
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_SIGNUP_TITLE"];
    emailLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_FIELD"];
    usernameLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_FIELD"];
    passwordLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_FIELD"];
    numberLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER_FIELD"];
    emailField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_PLACEHOLDER"];    
    usernameField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_PLACEHOLDER"];
    passwordField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_PASSWORD_PLACEHOLDER"];
    numberField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER2_PLACEHOLDER"];
    [usernameField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    [signupButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SIGNUP_LOGIN_ACTION"] forState:UIControlStateNormal];
    [signupButton setEnabled:NO];
    [signupButton setAlpha:0.6];
    // set view direction
    [[AppManager sharedManager] flipViewDirection:signupView];
}

// Clear data
- (void)clearData
{
    emailField.text = @"";
    usernameField.text = @"";
    passwordField.text = @"";
    numberField.text = @"";
    [signupButton setEnabled:NO];
    [signupButton setAlpha:0.6];
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

// Signup action
- (IBAction)signupAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // all data filled 
    if (([emailField.text length] > 0) && ([usernameField.text length] > 0) && ([passwordField.text length] > 0))
    {
        // password is too short
        if ([passwordField.text length] < 6)
            [[AppManager sharedManager] showNotification:@"SIGNIN_PASSWORD_SHORT"  withType:kNotificationTypeFailed];
        // check username
        else if ([usernameField.text length] < 5)
            [[AppManager sharedManager] showNotification:@"SIGNIN_USERNAME_SHORT_ERROR"  withType:kNotificationTypeFailed];
        // check eamil address
        else if (! [[AppManager sharedManager] validateEmail:emailField.text])
            [[AppManager sharedManager] showNotification:@"SIGNIN_EMAIL_ERROR"  withType:kNotificationTypeFailed];
        else // signup process
        {
            // start loader
            [loaderView setHidden:NO];
            [signupButton setEnabled:NO];
            [signupButton setAlpha:0.6];
            [signupView setUserInteractionEnabled:NO];
            [self processSignup];
        }
    }
}

// Process sign up
- (void)processSignup
{
    // fill in register info
    NSDictionary* registerInfo = @{@"email":emailField.text, @"username":usernameField.text,
                                   @"password":passwordField.text, @"number": numberField.text};
    // signup process
    [[ConnectionManager sharedManager] signupRegisterUser:registerInfo success:^(int resultFlag)
    {
        // singup process succeed
        if (resultFlag == 1)
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
                    [signupView setUserInteractionEnabled:YES];
                    [signupButton setEnabled:YES];
                    [signupButton setAlpha:1.0];
                    // go back to login
                    [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
                }
                failure:^(NSError *error)
                {
                    // stop loader
                    [loaderView setHidden:YES];
                    [signupView setUserInteractionEnabled:YES];
                    [signupButton setEnabled:YES];
                    [signupButton setAlpha:1.0];
                    // go back to login
                    [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
                }];
            }
            else// go back to login
            {
                // stop loader
                [loaderView setHidden:YES];
                [signupView setUserInteractionEnabled:YES];
                [signupButton setEnabled:YES];
                [signupButton setAlpha:1.0];
                [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
            }
        }
        // invalid user name
        else if (resultFlag == -1)
        {
            // stop loader
            [loaderView setHidden:YES];
            [signupView setUserInteractionEnabled:YES];
            [signupButton setEnabled:YES];
            [signupButton setAlpha:1.0];
            [[AppManager sharedManager] showNotification:@"SIGNUP_USERNAME_USED"  withType:kNotificationTypeFailed];
        }
        else
        {
            // stop loader
            [loaderView setHidden:YES];
            [signupView setUserInteractionEnabled:YES];
            [signupButton setEnabled:YES];
            [signupButton setAlpha:1.0];
            [[AppManager sharedManager] showNotification:@"SIGNUP_USERNAME_INVALID"  withType:kNotificationTypeFailed];
        }
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        [signupView setUserInteractionEnabled:YES];
        [signupButton setEnabled:YES];
        [signupButton setAlpha:1.0];
        // show notification error
        [[AppManager sharedManager] showNotification:@"MSG_LOGIN_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [emailField resignFirstResponder];
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    [numberField resignFirstResponder];
    // filled data
    [signupButton setEnabled:NO];
    [signupButton setAlpha:0.6];
    if (([emailField.text length] > 0) && ([usernameField.text length] > 0) && ([passwordField.text length] > 0))
    {
        [signupButton setEnabled:YES];
        [signupButton setAlpha:1.0];
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
        // email
        case kSignupEmailTag:
        {
            [usernameField becomeFirstResponder];
            break;
        }
        // username
        case kSignupUsernameTag:
        {
            [passwordField becomeFirstResponder];
            break;
        }
        // password
        case kSignupPasswordTag:
        {
            [numberField becomeFirstResponder];
            break;
        }
        // number
        case kSignupNumberTag:
        {
            [numberField resignFirstResponder];
            // signup action
            [self backgroundAction:nil];            
            [self signupAction:nil];
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

-(void) textFieldDidChange:(UITextField*) textField{
    NSString *originalString = textField.text;
    NSString *newString = [originalString stringByReplacingOccurrencesOfString:@" " withString:@"_" ];
    
    // remove special characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890.ضصثقفغعهخحجدذشسيبلاتنمكطئءؤرلاىةوزظْأإف"] invertedSet];
    NSString *resultString = [[newString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    resultString = [resultString lowercaseString];
    
    textField.text = resultString;
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
