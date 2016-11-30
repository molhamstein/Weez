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
#import "Event.h"
#import "WeezBaseViewController.h"

#define kProfileActionSheet 0
#define kCoverActionSheet   1

@interface EditEventController : WeezBaseViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                            RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, IBActionSheetDelegate, UIAlertViewDelegate>
{
    UIImageView *profileImageView;
    UIImageView *overlayImageView;
    UIImageView *coverImageView;
    UILabel *titleFieldLbl;
    UITextField *titleTextField;
    
    UILabel *locationTitle;
    UILabel *locationLabel;
    UILabel *startDateTitle;
    UILabel *startDateLabel;
    UIDatePicker *startDatePicker;
    UILabel *endDateTitle;
    UILabel *endDateLabel;
    UIDatePicker *endDatePicker;
    
    UIView *loaderView;
    UIView *formContainer;
    UIImage *pickedProfileImage;
    UIImage *pickedCoverImage;
    UIButton *saveButton;
    
    BOOL isEditingStartDate;
    BOOL isEditingEndDate;
    
    Event *event;
    Location *selectedLocation;
    int imageOptionTag;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UIImageView *overlayImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleFieldLbl;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UIView *loaderView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) IBOutlet UILabel *locationTitle;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *startDateTitle;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (strong, nonatomic) IBOutlet UILabel *endDateTitle;
@property (strong, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *startDatePickerHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *endDatePickerHeightConstraint;

@property (strong, nonatomic) Event *event;

- (IBAction)attachPhoto:(id)sender;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)pickStartDateAction:(id)sender;
- (IBAction)pickEndDateAction:(id)sender;
- (IBAction)pickLocationAction:(id)sender;
- (IBAction)saveEvent:(id)sender;
// Unwind location segue
- (IBAction)unwindUserLocationSegue:(UIStoryboardSegue*)segue;


@end

