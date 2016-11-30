//
//  RecordMediaController.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "RecordMediaController.h"
#import "AppManager.h"
#import "ViewUtils.h"
#import "PreviewMediaController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SocialManager.h"

@implementation RecordMediaController

@synthesize cameraController;
@synthesize errorLabel;
@synthesize switchButton;
@synthesize flashButton;
@synthesize recordButton;
@synthesize recordTimeView;
@synthesize redImageView;
@synthesize recordTimeLabel;
@synthesize pickedImage;
@synthesize videoURL;
@synthesize recordMediaFor;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure view
    [self configureView];
}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // start the camera
    [self.cameraController start];
    recordButton.enabled = YES;
    pickedImage = nil;
    videoURL = nil;
    timeOut = 0.0;
    isAnimating = NO;
    recordTimeLabel.text = [NSString stringWithFormat:@"00:%02d / 00:%i", (int)timeOut, MAX_VIDEO_LENGTH];
}

// View will layout subviews
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.cameraController.view.frame = self.view.contentBounds;
}

// Configure view controls
- (void)configureView
{
    // create camera vc
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.cameraController = [[LLSimpleCamera alloc] initWithQuality:AVCaptureSessionPresetHigh position:LLCameraPositionFront videoEnabled:YES];
    // attach to a view controller
    [self.cameraController attachToViewController:self withFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [self.view sendSubviewToBack:self.cameraController.view];
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.cameraController.fixOrientationAfterCapture = YES;
    // take the required actions on a device change
    __weak typeof(self) weakSelf = self;
    [self.cameraController setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device)
    {
        NSLog(@"Device changed.");
        // device changed, check if flash is available
        if([camera isFlashAvailable])
        {
            weakSelf.flashButton.hidden = NO;
            if (camera.flash == LLCameraFlashOff)
                weakSelf.flashButton.selected = NO;
            else
                weakSelf.flashButton.selected = YES;
        }
        else
            weakSelf.flashButton.hidden = YES;
    }];
    // set error handler
    [self.cameraController setOnError:^(LLSimpleCamera *camera, NSError *error)
    {
        NSLog(@"Camera error: %@", error);
        if ([error.domain isEqualToString:LLSimpleCameraErrorDomain])
        {
            if (error.code == LLSimpleCameraErrorCodeCameraPermission || error.code == LLSimpleCameraErrorCodeMicrophonePermission)
            {
                [[AppManager sharedManager] showNotification:@"RECORD_MEDIA_PERMISSION" withType:kNotificationTypeFailed];
            }
        }
    }];
    // switch button
    [self.switchButton setHidden:NO];
    if([self isFrontCameraAvailable] && [self isRearCameraAvailable])
        [self.switchButton setHidden:NO];
    // set image mode
    mediaType = kMediaTypeImage;
    timeOut = 0.0;
    isAnimating = NO;
    [recordTimeView setHidden:YES];
    recordTimeLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellLargeNumber];
    [self configureRecordButton];
}

// Configure record button
- (void)configureRecordButton
{
    // Configure colors
    self.recordButton.buttonColor = [UIColor whiteColor];
    self.recordButton.progressColor = [[AppManager sharedManager] getColorType:kAppColorBlue];
    // Add Targets
    [self.recordButton addTarget:self action:@selector(startVideoImageTimer) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchCancel];
}

// Start video image timer
- (void)startVideoImageTimer
{
    // image type
    mediaType = kMediaTypeImage;
    [recordTimeView setHidden:YES];
    // reset the timer
    [videoImageTimer invalidate];
    videoImageTimer = nil;
    // run the timer
    NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(startRecording:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sgn];
    [inv setTarget: self];
    [inv setSelector:@selector(startRecording:)];
    videoImageTimer = [NSTimer timerWithTimeInterval:1.0 invocation:inv repeats:NO];
    // run the timer
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:videoImageTimer forMode:NSDefaultRunLoopMode];
}

// Start recording
- (void)startRecording:(NSTimer*)timer
{
    if(self.cameraController.position == LLCameraPositionRear)
        self.cameraController.mirror = LLCameraMirrorOff;
    else
        self.cameraController.mirror = LLCameraMirrorOn;
    
    // video type
    mediaType = kMediaTypeVideo;
    [recordTimeView setHidden:NO];
    // start recording
    if (! self.cameraController.isRecording)
    {
        [self startRecordTimer];
    }
}

// Start snap
- (void)stopRecording
{
    // reset the timer
    [videoImageTimer invalidate];
    videoImageTimer = nil;
    __weak typeof(self) weakSelf = self;
    // image mode
    if (mediaType == kMediaTypeImage)
    {
        if(self.cameraController.position == LLCameraPositionRear)
            self.cameraController.mirror = LLCameraMirrorOff;
        else
            self.cameraController.mirror = LLCameraMirrorOn;

        // capture
        //self.cameraController.cameraQuality = AVCaptureSessionPresetPhoto;
        [self.cameraController capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error)
         {
             if (!error){
                 
                 weakSelf.pickedImage = image;
                 
                 //NSData *imageData = [NSData dataWithContentsOfURL:image];
                 //NSData *imageJPGData = UIImageJPEGRepresentation(image, 0.8);
                 //NSData *imagePNGData = UIImagePNGRepresentation(image);
                 // save media to photos album folder
//                 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//                 [library writeImageDataToSavedPhotosAlbum:imagePNGData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//                     NSLog(@"saved");
//                 }];
                 [weakSelf performSegueWithIdentifier:@"recordPreviewSegue" sender:self];
             }
             else
             {
                 NSLog(@"An error has occured: %@", error);
             }
         } exactSeenImage:YES];
    }
    else// video mode
    {
        // stop image timer
        [recordTimer invalidate];
        recordTimer = nil;

        // stop play image media
        [self stopRecorderTimer];
    }
}

// Cancel action
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

// Flash button pressed
- (IBAction)flashButtonPressed:(id)sender
{
    // flash is off
    if (self.cameraController.flash == LLCameraFlashOff )
    {
        BOOL done = [self.cameraController updateFlashMode:LLCameraFlashOn];
        if (done)
            self.flashButton.selected = YES;
    }
    else// flash is on
    {
        BOOL done = [self.cameraController updateFlashMode:LLCameraFlashOff];
        if (done)
            self.flashButton.selected = NO;
    }
}

// Switch camera
- (IBAction)switchButtonPressed:(id)sender
{
    [self.cameraController togglePosition];
}

// Get application documtnts directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Start record timer
- (void)startRecordTimer
{
    // reset the timer
    [recordTimer invalidate];
    recordTimer = nil;
    // run the timer
    NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(tickRecorder:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sgn];
    [inv setTarget: self];
    [inv setSelector:@selector(tickRecorder:)];
    recordTimer = [NSTimer timerWithTimeInterval:0.05 invocation:inv repeats:YES];
    // run the timer
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:recordTimer forMode:NSDefaultRunLoopMode];
    // start recorder
    self.flashButton.hidden = YES;
    self.switchButton.hidden = YES;
    // start recording
    NSURL *outputURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"recordedVideo"] URLByAppendingPathExtension:@"mp4"];
    //self.cameraController.cameraQuality = AVCaptureSessionPresetPhoto;
    [self.cameraController startRecordingWithOutputUrl:outputURL];
}

// Stop play image
- (void)tickRecorder:(NSTimer*)timer
{
    // count down 0
    if (timeOut >= MAX_VIDEO_LENGTH)
    {
        // stop image timer
        [recordTimer invalidate];
        recordTimer = nil;
        // stop play image media
        [self stopRecorderTimer];
    }
    else// reduce counter
    {
        if (! isAnimating)
        {
            isAnimating = YES;
            [UIView animateWithDuration:0.5f animations:^
            {
                self.redImageView.alpha = 0.f;
            }
            completion:^(BOOL finished)
            {
                [UIView animateWithDuration:0.5f animations:^
                {
                    self.redImageView.alpha = 1.f;
                }
                completion:^(BOOL finished)
                {
                    isAnimating = NO;
                }];
            }];
        }
        timeOut += 0.05;
        //recordTimeLabel.text = [NSString stringWithFormat:@"00:%02d / 00:%i", (int)timeOut, MAX_VIDEO_LENGTH];
        recordTimeLabel.text = [NSString stringWithFormat:@"%02d", (int)timeOut];
        [self.recordButton setProgress:(float)timeOut/(float)MAX_VIDEO_LENGTH];
    }
}

// Stop recorder timer
- (void)stopRecorderTimer
{
    __weak typeof(self) weakSelf = self;
    redImageView.hidden = NO;
    self.redImageView.alpha = 1.f;
    // stop recording
    self.flashButton.hidden = NO;
    self.switchButton.hidden = NO;
    self.recordButton.enabled = NO;
    [self.recordButton setProgress:0.0];
    [recordTimeView setHidden:YES];
    // stop recording
    [self.cameraController stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error)
    {
        weakSelf.videoURL = outputFileUrl;
        [weakSelf performSegueWithIdentifier:@"recordPreviewSegue" sender:self];
    }];
}

// Is front camera availabel
- (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// Is rear camera availabel
- (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

// Memory warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // user profile
    if ([[segue identifier] isEqualToString:@"recordPreviewSegue"])
    {
        // pass the active user to profile page
        PreviewMediaController *previewController = segue.destinationViewController;
        [previewController setMediaObject:mediaType withImage:pickedImage withVideoURL:videoURL];
        [previewController setRecordMediaFor:self.recordMediaFor];
    }
}

@end
