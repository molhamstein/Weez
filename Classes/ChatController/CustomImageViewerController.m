//
//  CustomImageViewerController.m
//  Weez
//
//  Created by Molham on 10/23/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "CustomImageViewerController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoordinatesDetailsController.h"
#import "TimelinesCollectionController.h"
#import "AppManager.h"
#import "ProfileController.h"
#import "UIImageView+WebCache.h"
#import "ChatMessage.h"

@implementation CustomImageViewerController

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
//        //self.imageInfo = imageInfo;
//        //self.mode = mode;
//        //self.backgroundOptions = backgroundOptions;
//        self.currentSnapshotRotationTransform = CGAffineTransformIdentity;
//        if (self.mode == JTSImageViewControllerMode_Image) {
//            [self setupImageAndDownloadIfNecessary:self.imageInfo];
//        }
//    }
//    return self;
//}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    // add location info
    CGRect parentFrame = self.view.frame;
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(10, parentFrame.size.height - 70, parentFrame.size.width-20, 70)];
    //_footerView.backgroundColor = [UIColor redColor];
    
    _locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 50, 50)];
    
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(_locationImageView.frame.size.width + 8 , 10, _footerView.frame.size.width-60, 30)];
    _locationLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    _locationLabel.textColor = [UIColor whiteColor];

    _locationButton = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, _footerView.frame.size.width, _footerView.frame.size.height)];
    [_locationButton addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:_locationImageView];
    [_footerView addSubview:_locationLabel];
    [_footerView addSubview:_locationButton];
    [self.view addSubview:_footerView];

    if(_mediaLocation && [_mediaLocation.objectId length] > 0){
        /// location image
        _locationImageView.image = [UIImage imageNamed:@"recordLocationIcon"];
        if(_mediaLocation.image && [_mediaLocation.image length] > 0){
            [_locationImageView sd_setImageWithURL:[NSURL URLWithString:_mediaLocation.image] placeholderImage:nil options:SDWebImageRetryFailed
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                                 _locationImageView.layer.cornerRadius = _locationImageView.frame.size.width/2;
                                         }];
        }
        _locationLabel.text = _mediaLocation.name;
    }else{
        _footerView.hidden = YES;
    }
    

    _senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 50, 50)];
    _senderImageView.layer.cornerRadius = _senderImageView.frame.size.width/2;
    _senderImageView.clipsToBounds = YES;
    
    _senderNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_senderImageView.frame.size.width + 28 , 10, self.view.frame.size.width - 100, 30)];
    _senderNameLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    _senderNameLabel.textColor = [UIColor whiteColor];
    
    UIButton *senderProfileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0 , 0, self.view.frame.size.width-60, 50)];
    [senderProfileBtn addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_senderImageView];
    [self.view addSubview:_senderNameLabel];
    [self.view addSubview:senderProfileBtn];

    if(_sender){
        if(_sender.profilePic && [_sender.profilePic length] > 0){
            [_senderImageView sd_setImageWithURL:[NSURL URLWithString:_sender.profilePic] placeholderImage:nil options:SDWebImageRetryFailed
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {}];
        }
        _senderNameLabel.text = _sender.username;
    }
}

-(void)refreshView{
    
    // add location info
    if(_mediaLocation && [_mediaLocation.objectId length] > 0){
        _footerView.hidden = NO;
        /// location image
        _locationImageView.image = [UIImage imageNamed:@"recordLocationIcon"];
        _locationImageView.layer.cornerRadius = _locationImageView.frame.size.width/2;
        if(_mediaLocation.image && [_mediaLocation.image length] > 0){
            [_locationImageView sd_setImageWithURL:[NSURL URLWithString:_mediaLocation.image] placeholderImage:nil options:SDWebImageRetryFailed
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                         }];
        }
        _locationLabel.text = _mediaLocation.name;
    }else{
        _footerView.hidden = YES;
    }

    // sender
    if(_sender){
        if(_sender.profilePic && [_sender.profilePic length] > 0){
            [_senderImageView sd_setImageWithURL:[NSURL URLWithString:_sender.profilePic] placeholderImage:nil options:SDWebImageRetryFailed
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {}];
        }
        _senderNameLabel.text = _sender.username;
        
        _senderImageView.hidden = NO;
        _senderNameLabel.hidden = NO;
    }else{
        _senderImageView.hidden = YES;
        _senderNameLabel.hidden = YES;
    }
}

-(void)prepareControllerWithLocation:(Location*)location user:(User*)user mediaArray:(NSMutableArray*)mediArray currentMediaIndex:(int)index{
    self.mediaLocation = location;
    self.sender = user;
    self.mediaArray = mediArray;
    self.currentMediIndex = index;
}

- (void)dismissingPanGestureRecognizerPanned:(UIPanGestureRecognizer *)panner{
    if (self.flags.scrollViewIsAnimatingAZoom || self.flags.isAnimatingAPresentationOrDismissal) {
        return;
    }
    
    CGPoint translation = [panner translationInView:panner.view];
//    CGPoint locationInView = [panner locationInView:panner.view];
    CGPoint velocity = [panner velocityInView:panner.view];
//    CGFloat vectorDistance = sqrtf(powf(velocity.x, 2)+powf(velocity.y, 2));
    
    if (panner.state != UIGestureRecognizerStateBegan && panner.state != UIGestureRecognizerStateChanged) {
        // if horozontal flick move to next/prev media
        if (ABS(translation.x) > ABS(translation.y*1.2) && ABS(translation.x) > 50 && ABS(velocity.x) > 170) {
            if(translation.x < 0){
                if([self getNextImageMessageIndex] != -1)
                    [self moveToChatMessageAtIndex:[self getNextImageMessageIndex] withVelocity:velocity];
                else
                    [self dismiss:YES];
            }else{
                if([self getPrevImageMessageIndex] != -1)
                    [self moveToChatMessageAtIndex:[self getPrevImageMessageIndex] withVelocity:velocity];
                else
                    [self dismiss:YES];
            }
            //else
        }else { // if vertical gesture, dimiss image
            [super dismissingPanGestureRecognizerPanned:panner];
        }
    }else{
        [super dismissingPanGestureRecognizerPanned:panner];
    }
}


-(void)moveOfScreen:(CGPoint)velocity{
    __weak CustomImageViewerController *weakSelf = self;
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.imageView] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(velocity.x*0.1, velocity.y*0.1);
    [push setTargetOffsetFromCenter:self.imageDragOffsetFromImageCenter forItem:self.imageView];
    push.action = ^{
        // Refresh View
        if ([weakSelf imageViewIsOffscreen]) {
            ChatMessage *msg = [_mediaArray objectAtIndex:_currentMediIndex];
            JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
            imageInfo.imageURL = [NSURL URLWithString:msg.media.mediaLink] ;
            imageInfo.referenceRect = self.view.frame;
            imageInfo.referenceView = self.view;
            [self setupImageAndDownloadIfNecessary:imageInfo];
            [self animateToNext];
            [self refreshView];
            
            [weakSelf.animator removeAllBehaviors];
            weakSelf.attachmentBehavior = nil;
        }
    };
    [self.animator removeBehavior:self.attachmentBehavior];
    [self.animator addBehavior:push];
}


-(int)getNextImageMessageIndex{
    if(_currentMediIndex >= [_mediaArray count]-1)
        return -1;
    
    for (int i = _currentMediIndex+1; i < [_mediaArray count]; i++) {
        ChatMessage *msg = [_mediaArray objectAtIndex:i];
        if(msg.media && msg.media.mediaType == kMediaTypeImage && msg.media.mediaLink){
            return i;
        }
    }
    return -1;
}

-(int)getPrevImageMessageIndex{
    if(_currentMediIndex <= 1)
        return -1;
    
    for (int i = _currentMediIndex-1; i < [_mediaArray count]; i--) {
        ChatMessage *msg = [_mediaArray objectAtIndex:i];
        if(msg.media && msg.media.mediaType == kMediaTypeImage && msg.media.mediaLink){
            return i;
        }
    }
    return -1;
}

-(void)moveToChatMessageAtIndex:(int)msgIndex withVelocity:(CGPoint)velocity{
    if(_mediaArray && (msgIndex) < [_mediaArray count]){
        ChatMessage *msg = [_mediaArray objectAtIndex:msgIndex];
        if(msg.media && msg.media.mediaType == kMediaTypeImage && msg.media.mediaLink){
            _currentMediIndex = msgIndex;
            [self moveOfScreen:velocity];
            [self prepareControllerWithLocation:msg.media.location user:msg.sender mediaArray:_mediaArray currentMediaIndex:_currentMediIndex];
        }
    }
}

- (IBAction)locationAction:(id)sender{
    if(!_mediaLocation || _mediaLocation.objectId.length <=0)
        return;
    if(_mediaLocation.isPrivateLocation){
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
            [[AppManager sharedManager] openGoogleMapsAppForLat:_mediaLocation.latitude andLong:_mediaLocation.longitude];
        }else{
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"NavControllerCoords"];
            CoordinatesDetailsController *vc = nc.viewControllers[0];
            [vc setCoordinatesLat:_mediaLocation.latitude andLong:_mediaLocation.longitude];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self presentViewController:nc animated:YES completion:nil];
        }
    }else{
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"NavControllerCollection"];
        TimelinesCollectionController *vc = nc.viewControllers[0];
        [vc setType:kCollectionTypeLocationTimelines withLocation:_mediaLocation withTag:nil withEvent:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self presentViewController:nc animated:YES completion:nil];
        //[self performSegueWithIdentifier:@"imageViewerTimelinesCollectionSegue" sender:self];
    }
}

- (IBAction)profileAction:(id)sender{
    if(!_sender)
        return;
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"NavControllerProfile"];
    ProfileController *vc = nc.viewControllers[0];
    [vc setProfileWithUser:_sender];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self presentViewController:nc animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}


@end
