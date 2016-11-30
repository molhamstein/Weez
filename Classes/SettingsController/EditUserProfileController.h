//
//  EditUserProfileController.h
//  Weez
//
//  Created by Molham on 7/18/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "IBActionSheet.h"
#import "WeezBaseViewController.h"

#define kSettingsEmailTag          0
#define kSettingsUsernameTag       1
#define kSettingsNameTag           2
#define kSettingsNumberTag         3

@interface EditUserProfileController : WeezBaseViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                            RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, IBActionSheetDelegate>
{
    UIImageView *profileImageView;
//    UIImageView *overlayImageView;
    UIButton *editPhotoButton;
    UILabel *emailFieldLbl;
    UITextField *emailTextField;
    UILabel *bioFieldLbl;
    UITextView *bioTextView;
    UILabel *usernameFieldLbl;
    UITextField *usernameTextField;
    UILabel *displaynameFieldLbl;
    UITextField *displaynameTextField;
    UILabel *numberFieldLbl;
    UITextField *numberTextField;
    UIButton *passwordButton;
    UIView *loaderView;
    UIView *formContainer;
    UIImage *pickedProfileImage;
    
    NSString *bioPlaceHolder;
}

@property(nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property(nonatomic, retain) IBOutlet UIButton *editPhotoButton;
//@property(nonatomic, retain) IBOutlet UIImageView *overlayImageView;
@property(nonatomic, retain) IBOutlet UILabel *emailFieldLbl;
@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, retain) IBOutlet UILabel *bioFieldLbl;
@property(nonatomic, retain) IBOutlet UITextView *bioTextView;
@property(nonatomic, retain) IBOutlet UILabel *usernameFieldLbl;
@property(nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property(nonatomic, retain) IBOutlet UILabel *displaynameFieldLbl;
@property(nonatomic, retain) IBOutlet UITextField *displaynameTextField;
@property(nonatomic, retain) IBOutlet UILabel *numberFieldLbl;
@property(nonatomic, retain) IBOutlet UITextField *numberTextField;
@property(nonatomic, retain) IBOutlet UIButton *passwordButton;
@property(nonatomic, retain) IBOutlet UIView *loaderView;
@property(nonatomic, retain) IBOutlet UIView *formContainer;

- (IBAction)attachPhoto:(id)sender;
- (IBAction)backgroundAction:(id)sender;

@end

