//
//  SignupController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSignupEmailTag          0
#define kSignupUsernameTag       1
#define kSignupPasswordTag       2
#define kSignupNumberTag         3

@interface SignupController : UIViewController <UITextFieldDelegate>
{
    UIView *signupView;
    UILabel *emailLabel;
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UILabel *numberLabel;
    UITextField *emailField;    
    UITextField *usernameField;
    UITextField *passwordField;
    UITextField *numberField;
    UIButton *signupButton;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UIView *signupView;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UITextField *numberField;
@property (nonatomic, retain) IBOutlet UIButton *signupButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (IBAction)signupAction:(id)sender;
- (IBAction)backgroundAction:(id)sender;

@end
