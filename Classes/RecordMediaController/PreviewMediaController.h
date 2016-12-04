//
//  PreviewMediaController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Constants.h"
#import "Location.h"
#import "Event.h"
#import "WeezBaseViewController.h"

@interface PreviewMediaController : WeezBaseViewController
{
    UIImage *pickedImage;
    NSURL *videoURL;
    AVPlayer *avPlayer;
    AVPlayerLayer *avPlayerLayer;
    UIView *playContainerView;
    UIImageView *pickedImageView;
    UIButton *backgroundButton;
    UIView *footerView;
    UIImageView *locationImageView;
    UILabel *locationLabel;
    UILabel *timeLabel;
    UIButton *cancelButton;
    UIButton *submitButton;
    UIButton *locationButton;
    UIButton *recipientsButton;
    UIButton *addTagButton;
    UIActivityIndicatorView *loaderView;
    NSString *locationId;
    Location *selectedLocation;
    NSString *eventId;
    Event *selectedEvent;
    MediaType mediaType;
    NSMutableArray *recepientsList;
    NSMutableArray *hashtags;
    NSMutableArray *groupList;
    BOOL isPublic;
    BOOL isPlaying;
    BOOL isFirstTime;
    BOOL isPreviewOnly;
    RecordMediaFor recordMediaFor; // used to indicate how we are planing to use the Media we record "post it to timeline or upload it to chat"
}

@property (strong, nonatomic) IBOutlet UIView *playContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *pickedImageView;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UIImageView *locationImageView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) IBOutlet UIButton *recipientsButton;
@property (strong, nonatomic) IBOutlet UIButton *addTagButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loaderView;
@property (strong, nonatomic) IBOutlet Location* selectedLocation;
@property (strong, nonatomic) IBOutlet Event *selectedEvent;
@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, retain) NSURL *videoURL;
@property RecordMediaFor recordMediaFor;
@property BOOL isPreviewOnly;


- (void)setMediaObject:(MediaType)type withImage:(UIImage*)image withVideoURL:(NSURL*)url;
- (IBAction)cancelAction:(id)sender;
- (IBAction)chooseLocation:(id)sender;
- (IBAction)chooseEvent:(id)sender;
- (IBAction)chooseRecipients:(id)sender;
- (IBAction)addTag:(id)sender;
- (IBAction)backgroundAction:(id)sender;
- (IBAction)submitMedia:(id)sender;
- (IBAction)unwindLocationSegue:(UIStoryboardSegue*)segue;
- (IBAction)unwindRecipientsSegue:(UIStoryboardSegue*)segue;

@end