//
//  PreviewMediaController.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "PreviewMediaController.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import "ViewUtils.h"
#import "UIImage+Crop.h"
#import "UIImageView+WebCache.h"
#import "LocationPickerController.h"
#import "RecipientsListController.h"
#import "CustomIOSAlertView.h"
#import "CoordinatesDetailsController.h"
#import "TimelinesCollectionController.h"

@implementation PreviewMediaController

@synthesize playContainerView;
@synthesize pickedImageView;
@synthesize backgroundButton;
@synthesize footerView;
@synthesize locationImageView;
@synthesize locationLabel;
@synthesize timeLabel;
@synthesize cancelButton;
@synthesize submitButton;
@synthesize locationButton;
@synthesize recipientsButton;
@synthesize loaderView;
@synthesize recordMediaFor;
@synthesize pickedImage;
@synthesize videoURL;
@synthesize isPreviewOnly;
@synthesize addTagButton;
@synthesize selectedLocation;

#pragma mark -
#pragma mark View Controller
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure view
    [self configureView];
    isFirstTime = YES;
}

// View will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // play video
    if (isFirstTime && (mediaType == kMediaTypeVideo))
    {
        [avPlayer play];
        isPlaying = YES;
        isFirstTime = NO;
    }
}

// Configure view controls
- (void)configureView
{
    // set font
    timeLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    locationLabel.text = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION"];
    // image type
    if (mediaType == kMediaTypeImage)
    {
        pickedImageView.contentMode = UIViewContentModeScaleAspectFit;
        pickedImageView.image = pickedImage;
        timeLabel.text = [NSString stringWithFormat:@"00:%02d", [[ConnectionManager sharedManager] userObject].imageDuration];
        // hide video mode
        [pickedImageView setHidden:NO];
        [playContainerView setHidden:YES];
        [backgroundButton setHidden:YES];
    }
    else // video layer
    {
        // the video player
        avPlayer = [AVPlayer playerWithURL:videoURL];
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
        // self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[avPlayer currentItem]];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        playContainerView.frame = self.view.frame;
        [playContainerView.layer addSublayer:avPlayerLayer];
        int videoDuration = (int)floor(CMTimeGetSeconds(avPlayer.currentItem.asset.duration));
        timeLabel.text = [NSString stringWithFormat:@"00:%02d", videoDuration];
        // hide video mode
        [pickedImageView setHidden:YES];
        [playContainerView setHidden:NO];
        [backgroundButton setHidden:NO];
    }
    // init values
    locationId = @"";
    //    selectedLocation = nil;
    eventId = @"";
    selectedEvent = nil;
    recepientsList = [[NSMutableArray alloc] init];
    hashtags = [[NSMutableArray alloc] init];
    groupList = [[NSMutableArray alloc] init];
    isPublic = YES;
    isPlaying = NO;
    // cant mention other users if the meadia was recorded to be submitted to chat
    if(recordMediaFor == kRecordMediaForChat)
        recipientsButton.hidden = YES;
    // flip footer view
    [[AppManager sharedManager] flipViewDirection:footerView];
    
    // in preview only mode hide action buttons and show selected location data if available
    if(isPreviewOnly){
        submitButton.hidden = YES;
        addTagButton.hidden = YES;
        recipientsButton.hidden = YES;
        timeLabel.hidden = YES;
        
        if(selectedLocation){
            locationLabel.text = selectedLocation.name;
            // location image
            locationImageView.hidden = NO;
            locationImageView.contentMode = UIViewContentModeScaleAspectFill;
            locationImageView.layer.masksToBounds = YES;
            PreviewMediaController __weak *weakSelf = self;
            // set thumbnail
            [locationImageView sd_setImageWithURL:[NSURL URLWithString:selectedLocation.image] placeholderImage:nil
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
             }];
        }else{
            footerView.hidden = YES;
        }
    }
    
}

// Set media object
- (void)setMediaObject:(MediaType)type withImage:(UIImage*)image withVideoURL:(NSURL*)url
{
    mediaType = type;
    pickedImage = image;
    videoURL = url;
}

// Cancel action
- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

// Choose location
- (IBAction)chooseLocation:(id)sender
{
    // stop video
    if (mediaType == kMediaTypeVideo)
    {
        [avPlayer pause];
        isPlaying = NO;
    }
    if(isPreviewOnly){
        if(!selectedLocation)
            return;
        if(selectedLocation.isPrivateLocation)
            [self performSegueWithIdentifier:@"previewMediaCoordinatesDetailsSegue" sender:self];
        else
            [self performSegueWithIdentifier:@"previewMediaTimelinesCollectionSegue" sender:self];
    }else
        [self performSegueWithIdentifier:@"previewMediaLocationSegue" sender:self];
}

- (IBAction)chooseEvent:(id)sender{
    // stop video
    if (mediaType == kMediaTypeVideo)
    {
        [avPlayer pause];
        isPlaying = NO;
    }
    [self performSegueWithIdentifier:@"previewMediaEventSegue" sender:self];
}

// Choose recipients
- (IBAction)chooseRecipients:(id)sender
{
    // stop video
    if (mediaType == kMediaTypeVideo)
    {
        [avPlayer pause];
        isPlaying = NO;
    }
    [self performSegueWithIdentifier:@"previewMediaRecipientsSegue" sender:self];
}

- (IBAction)addTag:(id)sender
{
    [addTagButton setEnabled:NO];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:[[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_CANCEL"], [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_OK"], nil]];
    UIView *alertContetn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 90)];
    // title
    UILabel *alertTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 60)];
    alertTitle.font = [[AppManager sharedManager] getFontType:kAppFontTitle];
    alertTitle.numberOfLines = 3;
    alertTitle.textAlignment= NSTextAlignmentCenter;
    alertTitle.text = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_TITLE"];
    
    //tag icon
    UIImageView *tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, 30, 30)];
    tagImageView.contentMode = UIViewContentModeCenter;
    tagImageView.layer.masksToBounds = YES;
    tagImageView.image = [UIImage imageNamed:@"tagIcon"];
    
    UITextField *alertInputField = [[UITextField alloc] initWithFrame:CGRectMake(40, 50, 220, 30)];
    alertInputField.placeholder = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_ADD_TAG_PLACEHOLDER"];
    alertInputField.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    [alertInputField addTarget:self action:@selector(textFieldDidChange:)forControlEvents:UIControlEventEditingChanged];
    
    [alertContetn addSubview:tagImageView];
    [alertContetn addSubview:alertTitle];
    [alertContetn addSubview:alertInputField];
    [alertView setContainerView: alertContetn];
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        [addTagButton setEnabled:YES];
        if (buttonIndex == 1){
            if(alertInputField.text && ![alertInputField.text isEqualToString:@""]){
                [hashtags addObject:alertInputField.text];
            }
        }
        [alertView close];
    }];
    [alertView show];
    // after show set the parentView to prevent orientaton change of alertview
    alertView.parentView = self.view;
    [alertInputField becomeFirstResponder];
}

-(void) textFieldDidChange:(UITextField*) textField{
    NSString *originalString = textField.text;
    NSString *newString = [originalString stringByReplacingOccurrencesOfString:@" " withString:@"_" ];
    
    // remove special characters
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890ضصثقفغعهخحجدذشسيبلاتنمكطئءؤرلاىةوزظْأإف"] invertedSet];
    NSString *resultString = [[newString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    resultString = [resultString lowercaseString];
    //NSLog (@"Result: %@", resultString);
    
    textField.text = resultString;
}


// Background action
- (IBAction)backgroundAction:(id)sender
{
    // video is playing
    if (isPlaying)
        [avPlayer pause];
    else// paused
        [avPlayer play];
    isPlaying = !isPlaying;
}

// Submit media
- (IBAction)submitMedia:(id)sender
{
    [submitButton setEnabled:NO];
    [locationButton setEnabled:NO];
    [recipientsButton setEnabled:NO];
    [backgroundButton setEnabled:NO];
    [addTagButton setEnabled:NO];
    if(recordMediaFor == kRecordMediaForTimeline){
        [loaderView startAnimating];
        // pause video
        [avPlayer pause];
        isPlaying = NO;
        // image media
        if (mediaType == kMediaTypeImage)
            [self processUpload:nil];
        else // video media
        {
            NSURL *outputURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"exportedVideo"] URLByAppendingPathExtension:@"mp4"];
            [self convertVideoToLowQuailtyWithInputURL:videoURL outputURL:outputURL handler:^(AVAssetExportSession *h)
             {
                 // no need to save it now
                 //[self saveToCameraRoll:outputURL];
                 [self processUpload:outputURL];
             }];
        }
    }else{ // if media was recorded to be used in chat then send the media back to the chat Controller
        [self performSegueWithIdentifier:@"unwindPreviewMediaSegue" sender:self];
    }
}

// Process uplading media
- (void)processUpload:(NSURL*)exportedURL
{
    // upload media
    // if picker location is not defined
    // we need to create location before uploading media
    if(selectedLocation && selectedLocation.isUnDefinedPlace){
        [[ConnectionManager sharedManager] uploadMedia:mediaType withCustomLocation:selectedLocation withEventId:eventId withVideo:exportedURL withImage:pickedImage
                                        withRecipients:recepientsList withGroups:groupList withPublic:isPublic
                                          withHashtags:(NSMutableArray*)hashtags
                                               success:^
         {
             [submitButton setEnabled:NO];
             [locationButton setEnabled:NO];
             [recipientsButton setEnabled:NO];
             [backgroundButton setEnabled:NO];
             [addTagButton setEnabled:NO];
             [loaderView stopAnimating];
             // show notification success
             [[AppManager sharedManager] showNotification:@"RECORD_MEDIA_UPLOAD_SUCCESS" withType:kNotificationTypeSuccess];
             // back to record
             [self dismissViewControllerAnimated:NO completion:nil];
         }
                                               failure:^(NSError *error, int errorCode)
         {
             [submitButton setEnabled:YES];
             [locationButton setEnabled:YES];
             [recipientsButton setEnabled:YES];
             [backgroundButton setEnabled:YES];
             [addTagButton setEnabled:YES];
             [loaderView stopAnimating];
             if (errorCode == 1)
                 [[AppManager sharedManager] showNotification:@"RECORD_MEDIA_UPLOAD_ERROR" withType:kNotificationTypeFailed];
             else // show notification error
                 [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }else{
        [[ConnectionManager sharedManager] uploadMedia:mediaType withLocation:locationId withEventId:eventId withVideo:exportedURL withImage:pickedImage
                                        withRecipients:recepientsList withGroups:groupList withPublic:isPublic
                                          withHashtags:(NSMutableArray*)hashtags
                                               success:^
         {
             [submitButton setEnabled:NO];
             [locationButton setEnabled:NO];
             [recipientsButton setEnabled:NO];
             [backgroundButton setEnabled:NO];
             [addTagButton setEnabled:NO];
             [loaderView stopAnimating];
             // show notification success
             [[AppManager sharedManager] showNotification:@"RECORD_MEDIA_UPLOAD_SUCCESS" withType:kNotificationTypeSuccess];
             // back to record
             [self dismissViewControllerAnimated:NO completion:nil];
         }
                                               failure:^(NSError *error, int errorCode)
         {
             [submitButton setEnabled:YES];
             [locationButton setEnabled:YES];
             [recipientsButton setEnabled:YES];
             [backgroundButton setEnabled:YES];
             [addTagButton setEnabled:YES];
             [loaderView stopAnimating];
             if (errorCode == 1)
                 [[AppManager sharedManager] showNotification:@"RECORD_MEDIA_UPLOAD_ERROR" withType:kNotificationTypeFailed];
             else // show notification error
                 [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR" withType:kNotificationTypeFailed];
         }];
    }
}

// Player item reach end
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [avPlayer pause];
    isPlaying = NO;
}

// Get application documtnts directory
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Save video to camera roll
- (void)saveToCameraRoll:(NSURL *)srcURL
{
    NSLog(@"srcURL: %@", srcURL);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error)
    {
        if (error)
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        else
            NSLog( @"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
    };
    // write to photos album
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:srcURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:srcURL completionBlock:videoWriteCompletionBlock];
    }
}

// Convert video to low quality
- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL outputURL:(NSURL*)outputURL handler:(void (^)(AVAssetExportSession* h))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
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
    if ([[segue identifier] isEqualToString:@"previewMediaLocationSegue"]){
        
        // pass the active user to profile page
        UINavigationController *navController = [segue destinationViewController];
        LocationPickerController *locationListController = (LocationPickerController*)[navController viewControllers][0];
        [locationListController prepareControllerWithlimitToOnlyNearLocations:recordMediaFor == kRecordMediaForTimeline initialMapPos:kCLLocationCoordinate2DInvalid enableTags:YES allowSelectingCoordinates:NO parentViewController:self];
        locationListController.listOfTags = hashtags;
        
    }else if([[segue identifier] isEqualToString:@"previewMediaCoordinatesDetailsSegue"]){
        
        UINavigationController *navController = [segue destinationViewController];
        CoordinatesDetailsController *coordDetailsController = (CoordinatesDetailsController*)[navController viewControllers][0];
        [coordDetailsController setCoordinatesLat:selectedLocation.latitude andLong:selectedLocation.longitude];
        
        // used only in preview-only mode
    }else if([[segue identifier] isEqualToString:@"previewMediaTimelinesCollectionSegue"]){
        
        UINavigationController *navController = [segue destinationViewController];
        TimelinesCollectionController *timelinesController = (TimelinesCollectionController*)[navController viewControllers][0];
        [timelinesController setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
        
    }else if ([[segue identifier] isEqualToString:@"previewMediaRecipientsSegue"]){
        
        UINavigationController *navController = [segue destinationViewController];
        RecipientsListController *recipientsController = (RecipientsListController*)[navController viewControllers][0];
        recipientsController.selectionMode = MULTIPLE;
    }
}

// Unwind location segue
- (IBAction)unwindLocationSegue:(UIStoryboardSegue*)segue
{
    // pass the active location to details
    LocationPickerController *detailsController = (LocationPickerController*)segue.sourceViewController;
    hashtags = detailsController.listOfTags;
    /// check if the user selected a location or event
    if(CLLocationCoordinate2DIsValid(detailsController.customSelectedCoord)){
        locationLabel.text = [[AppManager sharedManager] getLocalizedString:@"PRIVATE_LOCATION_NAME_PLACESHOLDER"];
        locationImageView.image = nil;
    }else if (detailsController.selectedLocation != nil || detailsController.selectedEvent != nil)
    {
        if(detailsController.selectedLocation){
            selectedLocation = detailsController.selectedLocation;
            locationId = selectedLocation.objectId;
            selectedEvent = nil;
            eventId = @"";
            locationLabel.text = selectedLocation.name;
            //            if(selectedLocation.isPrivateLocation)
            //                locationLabel.text = [[AppManager sharedManager] getLocalizedString:@"PRIVATE_LOCATION_NAME_PLACESHOLDER"];
            //            else
            
            
            //            locationImageView.hidden = NO;
            // location image
            locationImageView.contentMode = UIViewContentModeScaleAspectFill;
            locationImageView.layer.masksToBounds = YES;
            PreviewMediaController __weak *weakSelf = self;
            // set thumbnail
            [locationImageView sd_setImageWithURL:[NSURL URLWithString:selectedLocation.image] placeholderImage:nil
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
             }];
        }else if(detailsController.selectedEvent){ // selected event
            
            selectedEvent = detailsController.selectedEvent;
            eventId = detailsController.selectedEvent.objectId;
            selectedLocation = nil;
            locationId = @"";
            
            locationLabel.text = detailsController.selectedEvent.name;
            locationImageView.hidden = NO;
            // location image
            locationImageView.contentMode = UIViewContentModeScaleAspectFill;
            locationImageView.layer.masksToBounds = YES;
            PreviewMediaController __weak *weakSelf = self;
            // set thumbnail
            [locationImageView sd_setImageWithURL:[NSURL URLWithString:detailsController.selectedEvent.image] placeholderImage:nil
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 weakSelf.locationImageView.image = [[AppManager sharedManager] convertImageToCircle:weakSelf.locationImageView.image clipToCircle:YES withDiamter:60 borderColor:[UIColor clearColor] borderWidth:0 shadowOffSet:CGSizeMake(0, 0)];
             }];
        }
    }
    else// without location
    {
        eventId = @"";
        locationId = @"";
        locationLabel.text = [[AppManager sharedManager] getLocalizedString:@"RECORD_MEDIA_PICK_LOCATION"];
        locationImageView.hidden = YES;
    }
}

// Unwind recipients segue
- (IBAction)unwindRecipientsSegue:(UIStoryboardSegue*)segue
{
    RecipientsListController *detailsController = (RecipientsListController*)segue.sourceViewController;
    recepientsList = detailsController.selectedFollowingList;
    groupList = detailsController.selectedGroupList;
    isPublic = detailsController.isPublic;
    [self submitMedia:self];
}

@end
