//
//  LocationDetailsController.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "LocationDetailsController.h"
#import "AppManager.h"
#import "ConnectionManager.h"
#import "UIImageView+WebCache.h"
#import "MemberListCell.h"

@implementation LocationDetailsController

@synthesize locationContainerView;
@synthesize locationNameView;
@synthesize coverImageView;
@synthesize profileImageView;
@synthesize overlayImageView;
@synthesize attachPhotoButton;
@synthesize locationNameLabel;
@synthesize locationNameTextField;
@synthesize addressLabel;
@synthesize addressTextField;
// Map view
@synthesize mapViewContainer;
@synthesize googleMapView;
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
    [self refreshSaveButton];
    pickedProfileImage = nil;
}

// Set active group
- (void)setLocation:(Location*)location
{
    activeLocation = location;
}

// Configure view controls
- (void)configureViewControls
{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackPress) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    // edit location case
    if (activeLocation != nil)
    {
        locationNameTextField.text = activeLocation.name;
        addressTextField.text = activeLocation.address;
        LocationDetailsController __weak *weakSelf = self;
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:activeLocation.image] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            weakSelf.profileImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
        }];
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        coverImageView.layer.masksToBounds = YES;
        // set thumbnail
        [coverImageView sd_setImageWithURL:[NSURL URLWithString:activeLocation.cover] placeholderImage:nil
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
        }];
        city = activeLocation.city;
        country = activeLocation.country;
        countryCode = activeLocation.countryCode;
        latitude = activeLocation.latitude;
        longitude = activeLocation.longitude;
        // reload map
        [ self reloadMapAnnotation:YES];
    }
    else// add location case
    {
        [self clearData];
    }
    // loader view
    loaderView.layer.cornerRadius = LAYER_CORNER_RADIUS;
    [loaderView setHidden:YES];
    // title
    self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_TITLE"];
    // set text info
    [locationNameLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [locationNameTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [addressLabel setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    [addressTextField setFont:[[AppManager sharedManager] getFontType:kAppFontDescription]];
    locationNameLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_NAME_FIELD"];
    locationNameTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_NAME_PLACEHOLDER"];
    addressLabel.text = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_ADDRESS_FIELD"];
    addressTextField.placeholder = [[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_ADDRESS_PLACEHOLDER"];
    // save button
    [saveButton.titleLabel setFont:[[AppManager sharedManager] getFontType:kAppFontTitle]];
    [saveButton setTitle:[[AppManager sharedManager] getLocalizedString:@"LOCATION_DETAILS_SAVE"] forState:UIControlStateNormal];
    // hide loader
    [loaderView setHidden:YES];
    // overlay image view
    overlayImageView.layer.cornerRadius = 40;
    overlayImageView.layer.masksToBounds = YES;
    // map
    googleMapView.myLocationEnabled = NO;
    googleMapView.delegate = self;
    // add drop shadow
    //[[AppManager sharedManager] addViewDropShadow:locationContainerView];
    //[[AppManager sharedManager] addViewDropShadow:mapViewContainer];
    // flip view direction
    [[AppManager sharedManager] flipViewDirection:locationNameView];
}

- (void) onBackPress{
    if([self isFormValid]){
        [self saveLocationAction:nil];
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

-(BOOL) isFormValid{
    BOOL isValid = YES;
    // enable save button
    if ( ([locationNameTextField.text length] <= 0)){
        isValid = NO;
    }
    return isValid;
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

// Cancel action
- (void)cancelAction
{
    // hide keyboard
    if ([AppManager sharedManager].activeField != nil)
    {
        [[AppManager sharedManager].activeField resignFirstResponder];
        [AppManager sharedManager].activeField = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// Clear data
- (void)clearData
{
    locationNameTextField.text = @"";
    [locationNameTextField resignFirstResponder];
    addressTextField.text = @"";
    [addressTextField resignFirstResponder];
    profileImageView.image = nil;
    pickedProfileImage = nil;
    coverImageView.image = nil;
    pickedCoverImage = nil;
    [self refreshSaveButton];
    city = @"";
    country = @"";
    countryCode = @"";
    latitude = 1000;
    longitude = 1000;
    [self reloadMapAnnotation:NO];
}

// Enable/Disable save button
- (void)refreshSaveButton
{
    // disable save button
    [saveButton setEnabled:NO];
    [saveButton setAlpha:0.6];
    // enable save button
    if (([locationNameTextField.text length] > 0) && ([addressTextField.text length] > 0) && (latitude != 1000) && (longitude != 1000))
    {
        [saveButton setEnabled:YES];
        [saveButton setAlpha:1.0];
    }
}

// Save location action
- (IBAction)saveLocationAction:(id)sender
{
    // create location
    Location *modifiedLocation = [[Location alloc] init];
    modifiedLocation.objectId = @"";
    modifiedLocation.name = locationNameTextField.text;
    modifiedLocation.address = addressTextField.text;
    modifiedLocation.city = city;
    modifiedLocation.country = country;
    modifiedLocation.countryCode = countryCode;
    modifiedLocation.latitude = latitude;
    modifiedLocation.longitude = longitude;
    if (activeLocation != nil)
        modifiedLocation.objectId = activeLocation.objectId;
    // start loader
    [loaderView setHidden:NO];
    [self.view setUserInteractionEnabled:NO];
    [[ConnectionManager sharedManager] updateLocation:modifiedLocation withImage:pickedProfileImage withCover:pickedCoverImage success:^
    {
        // stop loader
        [loaderView setHidden:YES];
        [self.view setUserInteractionEnabled:YES];
        if (activeLocation == nil)
            [self clearData];
        [[AppManager sharedManager] showNotification:@"LOCATION_DETAILS_SUCCESS"  withType:kNotificationTypeSuccess];
        // go back to settings
        [self performSelector:@selector(cancelAction) withObject:nil afterDelay:0.0];
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

// Attach product image
- (IBAction)attachPhoto:(UIButton*)sender
{
    [locationNameTextField resignFirstResponder];
    [addressTextField resignFirstResponder];
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
    [locationNameTextField resignFirstResponder];
    [addressTextField resignFirstResponder];
}

// Receive memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Map
// Reload map annotation
- (void)reloadMapAnnotation:(BOOL)isFirstTime
{
    // clear map
    [googleMapView clear];
    // location exist
    if ((latitude != 1000) && (longitude != 1000))
    {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        marker.title = nil;
        marker.snippet = nil;
        marker.infoWindowAnchor = CGPointMake(0.5, 0.0);
        marker.icon = [UIImage imageNamed:@"mapAnnotation"];
        marker.map = googleMapView;
        // center map on fist time
        if (isFirstTime)
        {
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:[AppManager sharedManager].currenttUserLocation.coordinate zoom:12];
            [googleMapView setCamera:camera];
            CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude,longitude);
            [googleMapView moveCamera:[GMSCameraUpdate setTarget:locationCoordinate]];
        }
        else// refresh map
        {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            // get geocode reverse location
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error)
            {
                if ([placemarks count] > 0)
                {
                    // fill data
                    CLPlacemark *placemark = (CLPlacemark *)[placemarks objectAtIndex:0];
                    country = @"";
                    city = @"";
                    countryCode = @"";
                    if ([placemark.country length] > 0)
                        country = placemark.country;
                    if ([placemark.locality length] > 0)
                        city = placemark.locality;
                    if ([placemark.ISOcountryCode length] > 0)
                        countryCode = placemark.ISOcountryCode;
                    NSString *address = @"";
                    if ([placemark.name length] > 0)
                        address = placemark.name;
                    if ([placemark.thoroughfare length] > 0)
                    {
                        if ([address length] > 0)
                            address = [NSString stringWithFormat:@"%@, %@", address, placemark.thoroughfare];
                        else
                            address = placemark.thoroughfare;
                    }
                    if ([placemark.subLocality length] > 0)
                    {
                        if ([address length] > 0)
                            address = [NSString stringWithFormat:@"%@, %@", address, placemark.subLocality];
                        else
                            address = placemark.subLocality;
                    }
                    addressTextField.text = address;
                }
            }];
        }
    }
    else// current location
    {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:[AppManager sharedManager].currenttUserLocation.coordinate zoom:12];
        [googleMapView setCamera:camera];
    }
}

// Map view did tap at coordinate
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // save lat and long
    latitude = coordinate.latitude;
    longitude = coordinate.longitude;
    [self reloadMapAnnotation:NO];
    [self refreshSaveButton];
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
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
}

@end
