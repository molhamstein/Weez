//
//  SetUsernameController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "SetUsernameController.h"
#import "AppManager.h"
#import "ConnectionManager.h"

@implementation SetUsernameController

@synthesize usernameView;
@synthesize descriptionLabel;
@synthesize usernameLabel;
@synthesize usernameTextField;
@synthesize saveButton;
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
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // set fonts
    [saveButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [descriptionLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    // set text
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"NAV_SET_USERNAME_TITLE"];
    descriptionLabel.text = [[AppManager sharedManager] getLocalizedString:@"SET_USERNAME_DESC"];
    usernameLabel.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_FIELD"];
    usernameTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_PLACEHOLDER"];
    [saveButton setTitle:[[AppManager sharedManager] getLocalizedString:@"SET_USERNAME_ACTION"] forState:UIControlStateNormal];
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.6];
    
    [usernameTextField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    
    // set view direction
    [[AppManager sharedManager] flipViewDirection:usernameView];
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

// Clear data
- (void)clearData
{
    usernameTextField.text = @"";
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.6];
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

// Save action
- (IBAction)saveAction:(id)sender
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // check email address
    if ([usernameTextField.text length] > 0)
    {
        // start loader
        [loaderView setHidden:NO];
        [saveButton setEnabled:NO];
        [saveButton setAlpha:0.6];
        [usernameView setUserInteractionEnabled:NO];
        // process recovery
        [self processSave];
    }
}

// Process save
- (void)processSave
{
    User *me = [[ConnectionManager sharedManager].userObject copyWithZone:nil];
    me.username = usernameTextField.text;
    // signin process
    [[ConnectionManager sharedManager] updateUserInfo:me withImage:nil success:^
    {
        // stop loader
        [loaderView setHidden:YES];
        [saveButton setEnabled:YES];
        [saveButton setAlpha:1.0];
        [usernameView setUserInteractionEnabled:YES];
        // succeed
        [self clearData];
        // go back to login
        [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
    }
    failure:^(NSError *error, int errorCode)
    {
        // stop loader
        [loaderView setHidden:YES];
        [saveButton setEnabled:YES];
        [saveButton setAlpha:1.0];
        [usernameView setUserInteractionEnabled:YES];
        // show notification for email error
        if (errorCode == 1)
            [[AppManager sharedManager] showNotification:@"SET_USERNAME_ERROR" withType:kNotificationTypeFailed];
        else// connection error
            [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
    }];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [usernameTextField resignFirstResponder];
    // filled data
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.6];
    if ([usernameTextField.text length] > 0)
    {
        [saveButton setEnabled:YES];
        [saveButton setAlpha:1.0];
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
    [self saveAction:nil];
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
