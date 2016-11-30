//
//  SigninController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSigninUsernameTag      0
#define kSigninPasswordTag      1

@interface SigninController : UIViewController <UITextFieldDelegate>
{
    UIView *loginView;
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UITextField *usernameField;
    UITextField *passwordField;
    UIButton *signinButton;
    UIButton *forgetPassButton;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UIView *loginView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *signinButton;
@property (nonatomic, retain) IBOutlet UIButton *forgetPassButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (IBAction)signinAction:(id)sender;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)forgetPassAction:(id)sender;

@end
