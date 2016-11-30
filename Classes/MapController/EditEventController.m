//
//  EditUserProfileController.m
//  Weez
//
//  Created by Molham on 7/18/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "EditEventController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"
#import "UserOwnedLocationsController.h"

@implementation EditEventController

@synthesize profileImageView;
@synthesize overlayImageView;
@synthesize titleFieldLbl;
@synthesize titleTextField;
@synthesize startDateTitle;
@synthesize startDateLabel;
@synthesize startDatePicker;
@synthesize endDateTitle;
@synthesize endDateLabel;
@synthesize endDatePicker;
@synthesize event;
@synthesize loaderView;
@synthesize saveButton;
@synthesize locationLabel;
@synthesize locationTitle;
@synthesize coverImageView;

UIView *loaderView;
UIView *formContainer;
UIImage *pickedProfileImage;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure view
    [self configureView];
    // refresh view
    [self refreshView];
}

// Configure view controls
- (void)configureView
{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    //save button
//    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
//    rightButton.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
//    rightButton.frame = CGRectMake(0, 0, 80, 44);
//    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_SAVE"] forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventTouchUpInside];
//    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    // Initialize UIBarbuttonitem
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    if(event)
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_TITLE_EDIT"];
    else
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_TITLE"];
    
    [saveButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [saveButton setTitle:[[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_SAVE"] forState:UIControlStateNormal];
    
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    
    // set text info
    [titleFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [titleTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    titleFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_NAME"];
    titleTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_NAME_PLACEHOLDER"];
    
    [startDateTitle setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [startDateLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    startDateTitle.text = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_START_DATE"];
    
    [endDateTitle setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [endDateLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    endDateTitle.text = [[AppManager sharedManager] getLocalizedString:@"CREATE_EVENT_END_DATE"];
    
    [startDatePicker addTarget:self action:@selector(startDateDidChange:) forControlEvents:UIControlEventValueChanged];
    [endDatePicker addTarget:self action:@selector(endDateDidChange:) forControlEvents:UIControlEventValueChanged];
    
    // hide loader
    [loaderView setHidden:YES];
    // hide date pickers
    _endDatePickerHeightConstraint.constant = 0;
    _startDatePickerHeightConstraint.constant = 0;
    [self.view layoutIfNeeded];
    // overlay image view
    overlayImageView.layer.cornerRadius = 40;
    overlayImageView.layer.masksToBounds = YES;
    // flip view direction
    [[AppManager sharedManager] flipViewDirection:formContainer];
    
    if(event == nil)
        event = [[Event alloc] init];
    else{
        selectedLocation = event.location;
        startDatePicker.date = event.startDate;
        endDatePicker.date = event.endDate;
    }
}

// Refresh view
- (void)refreshView
{
    // fill Event info
    // profile image
    if(pickedProfileImage){
        self.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:pickedProfileImage clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    }else{
        EditEventController __weak *weakSelf = self;
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:event.image] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
         }];
    }
    
    // cover image
    if(pickedCoverImage){
        self.coverImageView.image = pickedCoverImage;
    }else{
        [coverImageView sd_setImageWithURL:[NSURL URLWithString:event.cover] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {}];
    }
    
    if(!titleTextField.text || [titleTextField.text isEqualToString:@""])
        titleTextField.text = event.name;
    locationLabel.text = selectedLocation.name;
    
    [self refreshDateViews];
}

- (void)refreshDateViews{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:EVENT_DISPLAY_DATE_FORMAT];
    //[formatter setDoesRelativeDateFormatting:YES];
    
    startDateLabel.text = [formatter stringFromDate:startDatePicker.date];
    endDateLabel.text = [formatter stringFromDate:endDatePicker.date];
}

// Cancel action
- (void)cancelAction{
    // dismiss view
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) onBackPress{
    
    if([self isFormValid]){
        [self saveEvent:nil];
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

-(BOOL) isFormValid{
    BOOL isValid = YES;
    if ([titleTextField.text length] == 0)
        isValid = NO;
    else if(selectedLocation == nil)
        isValid = NO;
    
    return isValid;
}

// Save settings
- (IBAction)saveEvent:(id)sender
{
    // check event name
    if ([titleTextField.text length] == 0)
        [[AppManager sharedManager] showNotification:@"CREATE_EVENT_ERROR_EMPTY_TITLE" withType:kNotificationTypeFailed];
    else if(selectedLocation == nil)
        [[AppManager sharedManager] showNotification:@"CREATE_EVENT_ERROR_EMPTY_LOCATION" withType:kNotificationTypeFailed];
    else // start saving
    {
        Event *newEvent = event;
        newEvent.name = titleTextField.text;
        newEvent.startDate = startDatePicker.date;
        newEvent.endDate = endDatePicker.date;

        // start loader
        [loaderView setHidden:NO];
        [self.view setUserInteractionEnabled:NO];
        [self backgroundAction:self];
        // update user info
        [[ConnectionManager sharedManager] updateEvent:newEvent withLocationId:selectedLocation.objectId withImage:pickedProfileImage withCover:pickedCoverImage success:^
        {
            [loaderView setHidden:YES];
            [self.view setUserInteractionEnabled:YES];
            // refresh view to reset all data
            //[self refreshView];
            [[AppManager sharedManager] showNotification:@"CREATE_EVENT_SUCCESS"  withType:kNotificationTypeSuccess];
            [self cancelAction];
        }
        failure:^(NSError *error, int errorCode)
        {
            [[AppManager sharedManager] showNotification:@"CREATE_EVENT_FAILED"  withType:kNotificationTypeFailed];
            [loaderView setHidden:YES];
            [self.view setUserInteractionEnabled:YES];
            // refresh view to reset all data
            [self refreshView];
            [self onSaveFailed];
        }];
    }
}

// Attach product image
- (IBAction)attachPhoto:(UIButton*)sender
{
    [titleTextField resignFirstResponder];
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
    btnOpenGallery.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnOpenGallery.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnOpenGallery.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnTakePhoto = [buttonsArray objectAtIndex:1];
    [btnTakePhoto setImage:[UIImage imageNamed:@"pickerCameraIcon"] forState:UIControlStateNormal];
    btnTakePhoto.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTakePhoto.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnTakePhoto.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    // get sender tag
    actionOptions.tag = sender.tag;
    imageOptionTag = (int)sender.tag;
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [titleTextField resignFirstResponder];
    
    // close date pickers if open
    if(isEditingStartDate)
        [self pickStartDateAction:nil];
    
    if(isEditingEndDate)
        [self pickEndDateAction:nil];
}

- (IBAction)pickLocationAction:(id)sender{
    [titleTextField resignFirstResponder];
    [self performSegueWithIdentifier:@"editEventUserLocationsSegue" sender:self];
}

- (IBAction)pickStartDateAction:(id)sender{
    CGFloat newAlpha = 0;
    CGFloat newConstant = 0;
    if(isEditingStartDate){
        newConstant = 0;
        newAlpha = 0;
    }else{
        newConstant = 216;
        newAlpha = 1;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.startDatePicker.alpha = newAlpha;
    } completion:^(BOOL finished) {
        isEditingStartDate = !isEditingStartDate;
        
        self.startDatePickerHeightConstraint.constant = newConstant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }];
    
    if(isEditingEndDate)
        [self pickEndDateAction:nil];
    [titleTextField resignFirstResponder];
}

- (IBAction)pickEndDateAction:(id)sender{
    CGFloat newAlpha = 0;
    CGFloat newConstant = 0;
    if(isEditingEndDate){
        newConstant = 0;
        newAlpha = 0;
    }else{
        newConstant = 216;
        newAlpha = 1;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.endDatePicker.alpha = newAlpha;
    } completion:^(BOOL finished) {
        isEditingEndDate = !isEditingEndDate;
        
        self.endDatePickerHeightConstraint.constant = newConstant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
    }];
    
    if(isEditingStartDate)
        [self pickStartDateAction:nil];
    [titleTextField resignFirstResponder];
}

- (IBAction)startDateDidChange:(id)sender {
    [self refreshDateViews];
}

- (IBAction)endDateDidChange:(id)sender {
    [self refreshDateViews];
}


// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Unwind location segue
- (IBAction)unwindUserLocationSegue:(UIStoryboardSegue*)segue
{
    // pass the active location to details
    UserOwnedLocationsController *detailsController = (UserOwnedLocationsController*)segue.sourceViewController;
    if (detailsController.selectedLocation != nil){
        selectedLocation = detailsController.selectedLocation;
        [self refreshView];
    }else// without location
    {
        
    }
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
    // profile photo
    if (imageOptionTag == kProfileActionSheet)
    {
        pickedProfileImage = croppedImage;
        profileImageView.image = croppedImage;
        profileImageView.image = [[AppManager sharedManager] convertImageToCircle:profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    }
    else// cover photo
    {
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        coverImageView.layer.masksToBounds = YES;
        pickedCoverImage = croppedImage;
        coverImageView.image = croppedImage;
    }
    [self.navigationController popViewControllerAnimated:NO];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
                  rotationAngle:(CGFloat)rotationAngle
{
    // profile photo
    if (imageOptionTag == kProfileActionSheet)
    {
        pickedProfileImage = croppedImage;
        profileImageView.image = croppedImage;
        profileImageView.image = [[AppManager sharedManager] convertImageToCircle:profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    }
    else// cover photo
    {
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        coverImageView.layer.masksToBounds = YES;
        pickedCoverImage = croppedImage;
        coverImageView.image = croppedImage;
    }
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
    CGSize maskSize;
    // profile photo mask
    if (imageOptionTag == kProfileActionSheet)
        maskSize = CGSizeMake(IMAGE_PROFILE_DIAMETER, IMAGE_PROFILE_DIAMETER);
    else// cover photo mask
        maskSize = CGSizeMake(controller.view.frame.size.width, IMAGE_COVER_HEIGHT);
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
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    // profile photo mask
    if (imageOptionTag == kProfileActionSheet)
    {
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        [bezierPath addArcWithCenter:center radius:IMAGE_PROFILE_DIAMETER/2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    }
    else// cover photo mask
    {
        CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGPoint point2 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        CGPoint point3 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        CGPoint point4 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
        [bezierPath moveToPoint:point1];
        [bezierPath addLineToPoint:point2];
        [bezierPath addLineToPoint:point3];
        [bezierPath addLineToPoint:point4];
    }
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
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    // Open gallery
    if (buttonIndex == 0)
    {
        // photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:nil];

        }
        else//not available
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_TITLE"]
                                                            message:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_MSG"] delegate:nil
                                                            cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_ACTION"]
                                                            otherButtonTitles:nil];
            [alert show];
        }
    }
    // take photo
    else if (buttonIndex == 1)
    {
        // check if camer available
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            // open image picker
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:NULL];
            
        }
        else//not available
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
    if(alertView.tag == 2){
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
    if([segue.identifier isEqualToString:@"editEventUserLocationsSegue"]){
        UserOwnedLocationsController *locationsController = (UserOwnedLocationsController*) segue.destinationViewController;
        locationsController.isSelectLocatonModeEnabled = YES;
    }
}

@end
