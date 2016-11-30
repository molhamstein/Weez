//
//  RecordMediaController.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "LLSimpleCamera.h"
#import "SDRecordButton.h"
#import "WeezBaseViewController.h"

@interface RecordMediaController : WeezBaseViewController
{
    LLSimpleCamera *cameraController;
    UILabel *errorLabel;
    UIButton *switchButton;
    UIButton *flashButton;
    SDRecordButton *recordButton;
    UIView *recordTimeView;
    UIImageView *redImageView;
    UILabel *recordTimeLabel;
    NSTimer *videoImageTimer;
    NSTimer *recordTimer;
    float timeOut;
    BOOL isAnimating;
    MediaType mediaType;
    UIImage *pickedImage;
    NSURL *videoURL;
    RecordMediaFor recordMediaFor; // used to indicate how we are planing to use the Media we record "post it to timeline or upload it to chat"
}

@property (strong, nonatomic) LLSimpleCamera *cameraController;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *switchButton;
@property (strong, nonatomic) IBOutlet UIButton *flashButton;
@property (strong, nonatomic) IBOutlet SDRecordButton *recordButton;
@property (strong, nonatomic) IBOutlet UIView *recordTimeView;
@property (strong, nonatomic) IBOutlet UIImageView *redImageView;
@property (strong, nonatomic) IBOutlet UILabel *recordTimeLabel;
@property (strong, nonatomic) UIImage *pickedImage;
@property (strong, nonatomic) NSURL *videoURL;
@property RecordMediaFor recordMediaFor;

- (IBAction)switchButtonPressed:(id)sender;
- (IBAction)flashButtonPressed:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

