//
//  GroupDetailsController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "GroupDetailsController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "AddMentionController.h"
#import "UIImageView+WebCache.h"
#import "MemberListCell.h"
#import "ChatController.h"

@implementation GroupDetailsController

@synthesize groupContainerView;
@synthesize groupNameView;
@synthesize profileImageView;
//@synthesize overlayImageView;
@synthesize attachPhotoButton;
@synthesize groupNameLabel;
@synthesize groupNameTextField;
@synthesize groupDescriptionLabel;
@synthesize groupDescriptionTextField;
@synthesize membersView;
@synthesize membersActionView;
@synthesize addMemeberButton;
@synthesize membersTitleLabel;
@synthesize membersTableView;
@synthesize noResultView;
@synthesize noResultLabel;
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
    [self refreshView];
    pickedProfileImage = nil;
}

// Set active group
- (void)setGroup:(Group*)group
{
    activeGroup = group;
}

// Configure view controls
- (void)configureViewControls{
    
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    // remove/leave group
    if (activeGroup != nil){
        
        // right button
        UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        // group admin
        if ([activeGroup.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId])
        {
            rightButton.frame = CGRectMake(0, 0, 18, 18);
            [rightButton setBackgroundImage:[UIImage imageNamed:@"navDeleteGroup"] forState:UIControlStateNormal];
            [groupNameTextField setEnabled:YES];
            [groupDescriptionTextField setEnabled:YES];
            [addMemeberButton setEnabled:YES];
            [attachPhotoButton setEnabled:YES];
            [attachPhotoButton setAlpha:1.0f];
        }
        else// memeber
        {
            rightButton.frame = CGRectMake(0, 0, 20, 20);
            [rightButton setBackgroundImage:[UIImage imageNamed:@"navLeaveGroup"] forState:UIControlStateNormal];
            [groupNameTextField setEnabled:NO];
            [groupDescriptionTextField setEnabled:NO];
            [addMemeberButton setEnabled:NO];
            [attachPhotoButton setEnabled:NO];
            [attachPhotoButton setAlpha:0.4f];
        }
        [rightButton addTarget:self action:@selector(leaveGroupAction) forControlEvents:UIControlEventTouchUpInside];
        // Initialize UIBarbuttonitem
        UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = barButton2;
        // fill members list
        membersList = [[NSMutableArray alloc] initWithArray:activeGroup.members];
        groupNameTextField.text = activeGroup.name;
        groupDescriptionTextField.text = activeGroup.description;
        GroupDetailsController __weak *weakSelf = self;
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:activeGroup.image] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
        }];
    }
    else// add group case
    {
        [self clearData];
    }
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // title
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_TITLE"];
    // set text info
    //group name
    [groupNameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [groupNameTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    groupNameLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_NAME_FIELD"];
    groupNameTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_NAME_PLACEHOLDER"];
    //group description
    [groupDescriptionLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [groupDescriptionTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    groupDescriptionLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_DESCRIPTION_FIELD"];
    groupDescriptionTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_DESCRIPTION_PLACEHOLDER"];
    
    [membersTitleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    // no result
    noResultLabel.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_NO_MEMBERS"];
    // save button
    [saveButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [saveButton setTitle:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_SAVE"] forState:UIControlStateNormal];
    //edit button
    [attachPhotoButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    
    //set underline to edit button title string
    NSString *edit = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EDIT"];
    NSMutableAttributedString *editUnderlined = [[NSMutableAttributedString alloc] initWithString:edit];
    NSRange range = NSMakeRange(0, [editUnderlined length]);
    [editUnderlined addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [editUnderlined addAttribute: NSForegroundColorAttributeName value:[[AppManager sharedManager] getColorType:kAppColorDarkBlue] range: range];
    [attachPhotoButton setAttributedTitle:editUnderlined forState:UIControlStateNormal];
    
    // hide loader
    [loaderView setHidden:YES];
    // overlay image view
//    overlayImageView.layer.cornerRadius = 40;
//    overlayImageView.layer.masksToBounds = YES;
    // add drop shadow
    //[[AppManager sharedManager] addViewDropShadow:groupContainerView];
    //[[AppManager sharedManager] addViewDropShadow:membersView];
    // flip view direction
    [[AppManager sharedManager] flipViewDirection:groupNameView];
    [[AppManager sharedManager] flipViewDirection:membersActionView];
    [[AppManager sharedManager] flipViewDirection:membersTableView];
}

// Cancel action
- (void)cancelAction{
    
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    // go back to list
    if (activeGroup != nil)
        [self.navigationController popViewControllerAnimated:YES];
    else// dismiss view
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onBackPress{
    
    if(activeGroup && ![activeGroup.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId]){
        [self cancelAction];
        return;
    }
    
    if([self isFormValid]){
        [self saveGroupAction:nil];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_MSG"]
                                                       delegate:self
                                              cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_ACTION"]
                                              otherButtonTitles:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_CNCL"], nil];
        alert.tag = 2;
        [alert show];
    }
}

-(void) onSaveFailed{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_MSG"]
                                                   delegate:self
                                          cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_ACTION"]
                                          otherButtonTitles:[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_EXIT_CNCL"], nil];
    alert.tag = 2;
    [alert show];
}

// Refresh view
- (void)refreshView
{
    // refresh data
    NSString *countStr = @"";
    [noResultView setHidden:NO];
    [membersTableView setHidden:YES];
    // members exist
    if ([membersList count] > 0)
    {
        countStr = [NSString stringWithFormat:@"(%i)", (int)[membersList count]];
        [noResultView setHidden:YES];
        [membersTableView setHidden:NO];
        [membersTableView reloadData];
    }
    membersTitleLabel.text = [[[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_COUNT"] stringByReplacingOccurrencesOfString:@"{count}" withString:countStr];
    // enable/disable save button
    [self refreshSaveButton];
}

// Clear data
- (void)clearData
{
    groupNameTextField.text = @"";
    [groupNameTextField resignFirstResponder];
    groupDescriptionTextField.text = @"";
    [groupDescriptionTextField resignFirstResponder];
    membersList = [[NSMutableArray alloc] init];
    //profileImageView.image = nil;
    pickedProfileImage = nil;
    [self refreshView];
}

// Enable/Disable save button
- (void)refreshSaveButton{
    
    // disable save button
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.6];
    int minCount = 0;
    if (activeGroup != nil)
        minCount = 1;
    // enable save button
    if (([membersList count] > minCount) && ([groupNameTextField.text length] > 0))
    {
        [saveButton setEnabled:YES];
        [saveButton setAlpha:1.0];
    }
    // remove/leave group
    if (activeGroup != nil)
    {
        // group admin
        if (! [activeGroup.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId])
        {
            // disable save button
            [saveButton setEnabled:NO];
            [saveButton setAlpha:0.6];
        }
    }
}

-(BOOL) isFormValid{
    
    int minCount = 0;
    if (activeGroup != nil)
        minCount = 1;
    
    BOOL isValid = YES;
    // enable save button
    if (([membersList count] <= minCount) || ([groupNameTextField.text length] <= 0)){
        isValid = NO;
    }
    return isValid;
}


// Save group action
- (IBAction)saveGroupAction:(id)sender
{
    NSMutableArray *membersIds = [[NSMutableArray alloc] init];
    // loop all friends and fetch ids
    for (Friend *obj in membersList)
    {
        // remove current user
        if (! [obj.objectId isEqualToString:[[ConnectionManager sharedManager] userObject].objectId])
            [membersIds addObject:obj.objectId];
    }
    // create group
    Group *modifiedGroup = [[Group alloc] init];
    modifiedGroup.objectId = @"";
    modifiedGroup.name = groupNameTextField.text;
    modifiedGroup.description = groupDescriptionTextField.text;
    modifiedGroup.members = membersIds;
    if (activeGroup != nil)
        modifiedGroup.objectId = activeGroup.objectId;
    // start loader
    [loaderView setHidden:NO];
    [self.view setUserInteractionEnabled:NO];
    [[ConnectionManager sharedManager] updateGroup:modifiedGroup withImage:pickedProfileImage success:^(Group *updatedGroup)
    {
        // stop loader
        [loaderView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        if (activeGroup == nil)
            [self clearData];
        [[AppManager sharedManager] showNotification:@"GROUP_DETAILS_SUCCESS"  withType:kNotificationTypeSuccess];
        // go back to settings
        if (activeGroup != nil)
            [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
        else// new group go to chat
        {
            activeGroup = updatedGroup;
            [self performSegueWithIdentifier:@"groupDetailsChatSegue" sender:self];
        }
        
    }
    failure:^(NSError *error, int errorCode)
    {
        // stop loader
        [loaderView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        [self onSaveFailed];
        // connection
        //[[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
    }];
}

// Leave group action
- (void)leaveGroupAction
{
    // leave group messages
    NSString *titleStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_LEAVE_TITLE"];
    NSString *msgStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_LEAVE_MSG"];
    NSString *actionStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_LEAVE_ACTION"];
    NSString *cancelStr = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    // delete group for admins
    if ([activeGroup.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId])
    {
        titleStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_DELETE_TITLE"];
        msgStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_DELETE_MSG"];
        actionStr = [[AppManager sharedManager] getLocalizedString:@"GROUP_DETAILS_DELETE_ACTION"];
    }
    // leave/delete group alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleStr
                                                    message:msgStr
                                                    delegate:self
                                                    cancelButtonTitle:cancelStr
                                                    otherButtonTitles:actionStr, nil];
    [alert show];
}

// Leave group
- (void)leaveGroupProcess
{
    // start loader
    [loaderView setHidden:NO];
    [self.view setUserInteractionEnabled:NO];
    [[ConnectionManager sharedManager] leaveGroup:activeGroup.objectId success:^
    {
        // stop loader
        [loaderView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        // leave group
        NSString *message = @"GROUP_DETAILS_LEAVE_SUCCESS";
        // delete group for admins
        if ([activeGroup.admins containsObject:[[ConnectionManager sharedManager] userObject].objectId])
            message = @"GROUP_DETAILS_DELETE_SUCCESS";
        [[AppManager sharedManager] showNotification:message  withType:kNotificationTypeSuccess];
        // go back to settings
        //[self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    failure:^(NSError *error)
    {
        // stop loader
        [loaderView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        // connection
        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
    }];
}

// Attach product image
- (IBAction)attachPhoto:(id)sender
{
    [groupNameTextField resignFirstResponder];
    [groupDescriptionTextField resignFirstResponder];
    // action sheet options
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList = @[[[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_FROM_GALLEREY"], [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_FROM_CAMERA"]];
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:2];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:0];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:1];
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:2];
    // add images
    NSArray *buttonsArray = [actionOptions buttons];
    UIButton *btnOpenGallery = [buttonsArray objectAtIndex:0];
    [btnOpenGallery setImage:[UIImage imageNamed:@"pickerGalleryIcon"] forState:UIControlStateNormal];
    [btnOpenGallery setImageEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 24)];
    btnOpenGallery.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnOpenGallery.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnOpenGallery.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnTakePhoto = [buttonsArray objectAtIndex:1];
    [btnTakePhoto setImage:[UIImage imageNamed:@"pickerCameraIcon"] forState:UIControlStateNormal];
    btnTakePhoto.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTakePhoto.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnTakePhoto.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}

// Add member action
- (IBAction)addMemberAction:(id)sender
{
    [self performSegueWithIdentifier:@"groupAddMentionSegue" sender:self];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [groupNameTextField resignFirstResponder];
    [groupDescriptionTextField resignFirstResponder];
}

// Delete group member
- (void)removeGroupMember:(UIButton*)sender
{
    int rowIndex = (int)sender.tag;
    // remove the object from list of votes
    [membersList removeObjectAtIndex:rowIndex];
    // remove member row
    [membersTableView beginUpdates];
    NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
    [membersTableView deleteRowsAtIndexPaths:@[myIndexPath] withRowAnimation:UITableViewRowAnimationRight];
    [membersTableView endUpdates];
    // refresh members view
    [self refreshView];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table view data source
// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Height for header
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

// Header title for each section
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

// Footer view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

// Height for row at index path
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // normal cell
    return CELL_USER_HEIGHT;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [membersList count];
}

// Cell for row at index path
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"memberListCell";
    // timeline list cell
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
    Friend *friendObj = [membersList objectAtIndex:indexPath.row];
    NSMutableArray *adminList = [[NSMutableArray alloc] init];
    [adminList addObject:[[ConnectionManager sharedManager] userObject].objectId];
    // group exist
    if (activeGroup != nil)
        adminList = activeGroup.admins;
    [cell populateMemberWithContent:friendObj withAdminList:adminList];
    // follow button
    cell.removeButton.tag = indexPath.row;
    [cell.removeButton addTarget:self action:@selector(removeGroupMember:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

// Select item
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark -
#pragma mark textField delegate
// Finish text editing
- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
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
    // refresh save button
    [self refreshSaveButton];
}

#pragma mark -
#pragma mark ImagePickerDelegate
// Image picker picked image
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIImage *attachedImage = info[UIImagePickerControllerOriginalImage];
    // open cropper
    [self openCropper:attachedImage];
    [reader dismissViewControllerAnimated:NO completion:NULL];
}

// Image picker canceled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// Navigation controller style
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark -
#pragma mark RSKImageCrop Delegate
// Open cropper
- (void)openCropper:(UIImage*)image
{
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCustom];
    imageCropVC.delegate = self;
    imageCropVC.dataSource = self;
    [self.navigationController pushViewController:imageCropVC animated:NO];
}

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:NO];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    pickedProfileImage = croppedImage;
    profileImageView.image = croppedImage;
    profileImageView.image = [[AppManager sharedManager] convertImageToCircle:profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    [self.navigationController popViewControllerAnimated:NO];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    pickedProfileImage = croppedImage;
    profileImageView.image = croppedImage;
    profileImageView.image = [[AppManager sharedManager] convertImageToCircle:profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    [self.navigationController popViewControllerAnimated:NO];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                  willCropImage:(UIImage *)originalImage
{
}

#pragma mark -
#pragma mark RSKImageCrop DataSource
// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize = CGSizeMake(IMAGE_PROFILE_DIAMETER, IMAGE_PROFILE_DIAMETER);
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    return maskRect;
}

// Returns a custom path for the mask.
- (UIBezierPath*)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:center radius:IMAGE_PROFILE_DIAMETER/2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [bezierPath closePath];
    return bezierPath;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    // If the image is not rotated, then the movement rect coincides with the mask rect.
    return controller.maskRect;
}

#pragma mark -
#pragma mark Actions Sheet
// Action sheet pressed button
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Open gallery
    if (buttonIndex == 0){
        // photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:nil];
            
        }else//not available
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_TITLE"]
                                                           message:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_MSG"] delegate:nil
                                                 cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_ACTION"]
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
    // take photo
    else if (buttonIndex == 1){
        // check if camer available
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            // open image picker
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:NULL];
            
        }else//not available
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[AppManager sharedManager] getLocalizedString:@"CAMERA_NOT_AVAILABLE_TITLE"]
                                                           message:[[AppManager sharedManager] getLocalizedString:@"CAMERA_NOT_AVAILABLE_MSG"] delegate:nil
                                                 cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"CAMERA_NOT_AVAILABLE_ACTION"]
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark -
#pragma mark AlertView Delegate
// Alert view action clicked
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){ // leave group alert
        // leave/delete group
        if (buttonIndex == 1){
            [self leaveGroupProcess];
        }
    }else if(alertView.tag == 2){
        if (buttonIndex == 0)
            [self cancelAction];
    }
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"groupAddMentionSegue"])
    {
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        AddMentionController *addMentionController = (AddMentionController*)[navController viewControllers][0];
        addMentionController.selectionMode = MULTIPLE;
        [addMentionController setMentionListType:kTimelineTypeGroup];
        [addMentionController setMentionType:kEventMentionToCreateGroup];
    }
    else if ([[segue identifier] isEqualToString:@"groupDetailsChatSegue"])
    {
        // pass the active user to profile page
        ChatController *chatController = (ChatController*)[segue destinationViewController];
        [chatController setGroup:activeGroup withParent:self];
    }
}

// Unwind mention segue
- (IBAction)unwindAddGroupSegue:(UIStoryboardSegue*)segue
{
    // pass the active game to details
    AddMentionController *detailsController = (AddMentionController*)segue.sourceViewController;
    NSMutableArray *selectedUsers = [[NSMutableArray alloc] initWithArray:detailsController.mentionedList];
    // add selected users to members list
    for (Friend *obj in selectedUsers)
    {
        BOOL isFound = NO;
        // add unique users
        for (Friend *user in membersList)
        {
            if ([user.objectId isEqualToString:obj.objectId])
                isFound = YES;
        }
        // not exist before add to members list
        if (! isFound)
            [membersList addObject:obj];
    }
    // refresh view
    [self refreshView];
}

@end
