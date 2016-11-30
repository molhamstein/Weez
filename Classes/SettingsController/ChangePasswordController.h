//
//  ChangePasswordController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeezBaseViewController.h"

#define kChangeOldPassTag          0
#define kChangeNewPassTag          1
#define kChangeConfirmPassTag      2

@interface ChangePasswordController : WeezBaseViewController <UITextFieldDelegate>
{
    UIView *changePassView;
    UILabel *oldPassLabel;
    UILabel *nPassLabel;
    UILabel *confirmPassLabel;
    UITextField *oldPassField;
    UITextField *nPassField;
    UITextField *confirmPassField;
    UIButton *changePassButton;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UIView *changePassView;
@property (nonatomic, retain) IBOutlet UILabel *oldPassLabel;
@property (nonatomic, retain) IBOutlet UILabel *nPassLabel;
@property (nonatomic, retain) IBOutlet UILabel *confirmPassLabel;
@property (nonatomic, retain) IBOutlet UITextField *oldPassField;
@property (nonatomic, retain) IBOutlet UITextField *nPassField;
@property (nonatomic, retain) IBOutlet UITextField *confirmPassField;
@property (nonatomic, retain) IBOutlet UIButton *changePassButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (IBAction)changePassAction:(id)sender;
- (IBAction)backgroundAction:(id)sender;

@end
