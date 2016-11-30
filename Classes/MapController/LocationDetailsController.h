//
//  LocationDetailsController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSKImageCropper/RSKImageCropper.h>
#import "IBActionSheet.h"
#import "Location.h"
@import GoogleMaps;
#import "WeezBaseViewController.h"

#define kProfileActionSheet 0
#define kCoverActionSheet   1

@interface LocationDetailsController : WeezBaseViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                                GMSMapViewDelegate, IBActionSheetDelegate, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, UIAlertViewDelegate>
{
    UIView *locationContainerView;
    UIView *locationNameView;
    UIImageView *coverImageView;
    UIImageView *profileImageView;
    UIImageView *overlayImageView;
    UIButton *attachPhotoButton;
    UILabel *locationNameLabel;
    UITextField *locationNameTextField;
    UILabel *addressLabel;
    UITextField *addressTextField;
    // Map view
    UIView *mapViewContainer;
    GMSMapView *googleMapView;
    UIButton *saveButton;
    UIView *loaderView;
    UIImage *pickedProfileImage;
    UIImage *pickedCoverImage;
    NSString *city;
    NSString *country;
    NSString *countryCode;
    float latitude;
    float longitude;
    Location *activeLocation;
    int imageOptionTag;
}

@property (nonatomic, retain) IBOutlet UIView *locationContainerView;
@property (nonatomic, retain) IBOutlet UIView *locationNameView;
@property (nonatomic, retain) IBOutlet UIImageView *coverImageView;
@property (nonatomic, retain) IBOutlet UIImageView *profileImageView;
@property (nonatomic, retain) IBOutlet UIImageView *overlayImageView;
@property (nonatomic, retain) IBOutlet UIButton *attachPhotoButton;
@property (nonatomic, retain) IBOutlet UILabel *locationNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *locationNameTextField;
@property (nonatomic, retain) IBOutlet UILabel *addressLabel;
@property (nonatomic, retain) IBOutlet UITextField *addressTextField;
// Map view
@property (nonatomic, retain) IBOutlet UIView *mapViewContainer;
@property (nonatomic, retain) IBOutlet GMSMapView *googleMapView;
@property (nonatomic, retain) IBOutlet UIButton *saveButton;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

- (void)setLocation:(Location*)location;
- (IBAction)saveLocationAction:(id)sender;
- (IBAction)attachPhoto:(UIButton*)sender;
- (IBAction)backgroundAction:(id)sender;

@end
