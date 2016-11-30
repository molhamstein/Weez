//
//  GroupDetailsController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "IBActionSheet.h"
#import "Group.h"
#import "WeezBaseViewController.h"

@interface GroupDetailsController : WeezBaseViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate,
                                                            UINavigationControllerDelegate, IBActionSheetDelegate, UIAlertViewDelegate,
                                                            RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource>
{
    UIView *groupContainerView;
    UIView *groupNameView;
    UIImageView *profileImageView;
//    UIImageView *overlayImageView;
    UIButton *attachPhotoButton;
    UILabel *groupNameLabel;
    UITextField *groupNameTextField;
    UILabel *groupDescriptionLabel;
    UITextField *groupDescriptionTextField;
    UIView *membersView;
    UIView *membersActionView;
    UIButton *addMemeberButton;
    UILabel *membersTitleLabel;
    UITableView *membersTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIButton *saveButton;
    UIView *loaderView;
    UIImage *pickedProfileImage;
    Group *activeGroup;
    NSMutableArray *membersList;
}

@property (nonatomic, retain) IBOutlet UIView *groupContainerView;
@property (nonatomic, retain) IBOutlet UIView *groupNameView;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
//@property (nonatomic, retain) IBOutlet UIImageView *overlayImageView;
@property (nonatomic, retain) IBOutlet UIButton *attachPhotoButton;
@property (nonatomic, retain) IBOutlet UILabel *groupNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *groupNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *groupDescriptionLabel;
@property (nonatomic, retain) IBOutlet UITextField *groupDescriptionTextField;
@property (nonatomic, retain) IBOutlet UIView *membersView;
@property (nonatomic, retain) IBOutlet UIView *membersActionView;
@property (nonatomic, retain) IBOutlet UIButton *addMemeberButton;
@property (nonatomic, retain) IBOutlet UILabel *membersTitleLabel;
@property (nonatomic, retain) IBOutlet UITableView *membersTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (void)setGroup:(Group*)group;
- (IBAction)saveGroupAction:(id)sender;
- (IBAction)attachPhoto:(id)sender;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)addMemberAction:(id)sender;

@end
