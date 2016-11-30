//
//  SetUsernameController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUsernameController : UIViewController <UITextFieldDelegate>
{
    UIView *usernameView;
    UILabel *descriptionLabel;
    UILabel *usernameLabel;
    UITextField *usernameTextField;
    UIButton *saveButton;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UIView *usernameView;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (IBAction)backgroundAction:(id)sender;
- (IBAction)saveAction:(id)sender;

@end
