//
//  LoginController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppNotification.h"

#define kSigninUsernameTag      0
#define kSigninPasswordTag      1

@interface LoginController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITextFieldDelegate>
{
    // login view
    UIView *loginView;
    UIButton *facebookButton;
    UIButton *signupButton;
    UIView *footerView;
    UILabel *footerLabel;
    UIView *loaderView;
    
    //login form
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UITextField *usernameField;
    UITextField *passwordField;
    UIButton *signinButton;
    UIButton *forgetPassButton;
    
    // intro view
    NSArray *introInfo;
    UICollectionView *introCollectionView;
    UIPageControl *introPager;
    
    //recieved push notification payload
    AppNotification* appNotification;
}

// login view
@property(nonatomic, retain) IBOutlet UIView *loginView;
@property(nonatomic, retain) IBOutlet UIButton *facebookButton;
@property(nonatomic, retain) IBOutlet UIButton *signupButton;
@property(nonatomic, retain) IBOutlet UIView *footerView;
@property(nonatomic, retain) IBOutlet UILabel *footerLabel;
@property(nonatomic, retain) IBOutlet UIView *loaderView;
// login form
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *signinButton;
@property (nonatomic, retain) IBOutlet UIButton *forgetPassButton;
// intro view
@property(nonatomic, retain) IBOutlet UICollectionView *introCollectionView;
@property(nonatomic, retain) IBOutlet UIPageControl *introPager;

- (IBAction)login:(id)sender;
- (IBAction)signinAction:(id)sender;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)forgetPassAction:(id)sender;
- (IBAction)unwindLogoutSegue:(UIStoryboardSegue*)segue;
- (void)setRecievedNotification:(AppNotification*)data;

@end