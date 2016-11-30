//
//  EditUserProfileController.m
//  Weez
//
//  Created by Molham on 7/18/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "EditUserProfileController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"

@implementation EditUserProfileController

@synthesize profileImageView;
//@synthesize overlayImageView;
@synthesize editPhotoButton;
@synthesize emailFieldLbl;
@synthesize emailTextField;
@synthesize bioFieldLbl;
@synthesize bioTextView;
@synthesize usernameFieldLbl;
@synthesize usernameTextField;
@synthesize displaynameFieldLbl;
@synthesize displaynameTextField;
@synthesize numberFieldLbl;
@synthesize numberTextField;
@synthesize passwordButton;
@synthesize loaderView;
@synthesize formContainer;

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
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    //save button
    UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    rightButton.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentRight;
    rightButton.frame = CGRectMake(0, 0, 80, 44);
    [rightButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_SAVE"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveSettings) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    // Initialize UIBarbuttonitem
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"SETTINGS_PROFILE_SETTINGS"];
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    
    // set text info
    [bioFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [bioTextView setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    bioFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_BIO_FIELD"];
    bioPlaceHolder =  [[AppManager sharedManager] getLocalizedString:@"SIGNIN_BIO_PLACEHOLDER"];
    bioTextView.text = bioPlaceHolder;
    bioTextView.textColor = [UIColor lightGrayColor]; //optional
    
    [emailFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [emailTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    emailFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_EMAIL_FIELD"];
    emailTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_EMAIL_PLACEHOLDER"];
    [usernameFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [usernameTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    usernameFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_FIELD"];
    usernameTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_USERNAME_PLACEHOLDER"];
    [displaynameFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [displaynameTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    displaynameFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_NAME_FIELD"];
    displaynameTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"PROFILE_EDIT_NAME_PLACEHOLDER"];
    [numberFieldLbl setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [numberTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    numberFieldLbl.text = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER_FIELD"];
    numberTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"SIGNIN_NUMBER2_PLACEHOLDER"];
    
    [usernameTextField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    
    // change password
    // logout button
    passwordButton.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontTitle];
    [passwordButton setTitle:[[AppManager sharedManager] getLocalizedString:@"PREF_CHANGE_PSW"] forState:UIControlStateNormal];
    //edit photo
    editPhotoButton.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    
    //set underline to edit button title string
    NSString *edit = [[AppManager sharedManager] getLocalizedString:@"PREF_EDIT_PHOTO"];
    NSMutableAttributedString *editUnderlined = [[NSMutableAttributedString alloc] initWithString:edit];
    NSRange range = NSMakeRange(0, [editUnderlined length]);
    [editUnderlined addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
    [editUnderlined addAttribute: NSForegroundColorAttributeName value:[[AppManager sharedManager] getColorType:kAppColorDarkBlue] range: range];
    [editPhotoButton setAttributedTitle:editUnderlined forState:UIControlStateNormal];
    
    // hide loader
    [loaderView setHidden:YES];
    // overlay image view
//    overlayImageView.layer.cornerRadius = 40;
//    overlayImageView.layer.masksToBounds = YES;
    // flip view direction
    [[AppManager sharedManager] flipViewDirection:formContainer];
}

// Refresh view
- (void)refreshView
{
    // fill user info
    User *me = [ConnectionManager sharedManager].userObject;
    if(me.bio == nil || [me.bio isEqualToString:@""])
    {
        bioTextView.text = bioPlaceHolder;
        bioTextView.textColor = [UIColor lightGrayColor];
    }
    else
    {
        bioTextView.text = me.bio;
        bioTextView.textColor = [UIColor blackColor];
    }
    emailTextField.text = me.email;
    usernameTextField.text = me.username;
    //displaynameTextField.text = me.username;
    numberTextField.text = me.phoneNumber;
    EditUserProfileController __weak *weakSelf = self;
    [profileImageView sd_setImageWithURL:[NSURL URLWithString:me.profilePic] placeholderImage:nil options:SDWebImageRefreshCached
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
    }];
    pickedProfileImage = nil;
    
    //dismiss keyboard when touching out
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self.navigationController popViewControllerAnimated:YES];
}

// Save settings
- (void)saveSettings
{
    // check email address
    if (! [[AppManager sharedManager] validateEmail:emailTextField.text])
        [[AppManager sharedManager] showNotification:@"SIGNIN_EMAIL_ERROR" withType:kNotificationTypeFailed];
    // check username
    else if ([usernameTextField.text length] == 0)
    {
        [[AppManager sharedManager] showNotification:@"SIGNUP_USERNAME_INVALID" withType:kNotificationTypeFailed];
    }
    // check display name
//    else if ([displaynameTextField.text length] == 0)
//    {
//        [[AppManager sharedManager] showNotification:@"SIGNUP_DISPLAYNAME_EMPTY" withType:kNotificationTypeFailed];
//    }
    else // start saving
    {
        User *newUser = [ConnectionManager sharedManager].userObject.copy;
        if(![bioTextView.text isEqualToString:bioPlaceHolder])
            newUser.bio = bioTextView.text;
        newUser.email = emailTextField.text;
        newUser.username = usernameTextField.text;
        newUser.displayName = usernameTextField.text;
        newUser.phoneNumber = numberTextField.text;
        // start loader
        [loaderView setHidden:NO];
        [self.view setUserInteractionEnabled:NO];
        [self backgroundAction:self];
        // update user info
        [[ConnectionManager sharedManager] updateUserInfo:newUser withImage:pickedProfileImage success:^
        {
            [loaderView setHidden:YES];
            [self.view setUserInteractionEnabled:YES];
            // refresh view to reset all data
            //[self refreshView];
            [[AppManager sharedManager] showNotification:@"PROFILE_EDIT_SUCCESS"  withType:kNotificationTypeSuccess];
        }
        failure:^(NSError *error, int errorCode)
        {
            [loaderView setHidden:YES];
            [self.view setUserInteractionEnabled:YES];
            // refresh view to reset all data
            [self refreshView];
            // error username or email
            if (errorCode == 1)
                [[AppManager sharedManager] showNotification:@"SIGNUP_USERNAME_USED"  withType:kNotificationTypeFailed];
            else// connection
                [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
        }];
    }
}

-(void) textFieldDidChange:(UITextField*) textField{
    NSString *originalString = textField.text;
    NSString *newString = [originalString stringByReplacingOccurrencesOfString:@" " withString:@"_" ];
    
    // remove special characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890.ضصثقفغعهخحجدذشسيبلاتنمكطئءؤرلاىةوزظْأإف"] invertedSet];
    NSString *resultString = [[newString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    resultString = [resultString lowercaseString];
    
    textField.text = resultString;
}

// Attach product image
- (IBAction)attachPhoto:(id)sender
{
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
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;
    //[messageBox resignFirstResponder];
}

// Background action
- (IBAction)backgroundAction:(id)sender
{
    [emailTextField resignFirstResponder];
    [usernameTextField resignFirstResponder];
    //[displaynameTextField resignFirstResponder];
    [numberTextField resignFirstResponder];
    [bioTextView resignFirstResponder];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}
// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
#pragma mark textView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:bioPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = bioPlaceHolder;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
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
- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage
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
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
