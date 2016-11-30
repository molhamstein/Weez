//
//  ResetPasswordController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordController : UIViewController <UITextFieldDelegate>
{
    UIView *recoveryView;
    UILabel *recoveryLabel;
    UILabel *emailLabel;
    UILabel *numberLabel;
    UITextField *emailTextField;
    UITextField *numberTextField;
    UIButton *recoveryButton;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UIView *recoveryView;
@property (nonatomic, retain) IBOutlet UILabel *recoveryLabel;
@property (nonatomic, retain) IBOutlet UILabel *emailLabel;
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *numberTextField;
@property (nonatomic, retain) IBOutlet UIButton *recoveryButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (IBAction)backgroundAction:(id)sender;
- (IBAction)recoveryAction:(id)sender;

@end
